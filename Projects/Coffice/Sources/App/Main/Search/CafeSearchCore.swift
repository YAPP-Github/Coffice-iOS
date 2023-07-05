//
//  CafeSearchCore.swift
//  coffice
//
//  Created by sehooon on 2023/07/03.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import Foundation
import Network
import SwiftUI

struct CafeSearchCore: ReducerProtocol {
  enum PreviousViewType {
    case mapView
    case searchListView
  }

  enum CafeSearchViewBodyType {
    case recentSearchListView
    case searchResultEmptyView
    case searchResultListView
  }

  struct State: Equatable {
    @BindingState var searchText = ""
    var recentSearchKeyWordList: [SearchWordResponseDTO] = []
    var stationList: [String] = []
    var cafeList: [String] = []
    var currentBodyType: CafeSearchViewBodyType = .searchResultListView
    var previousViewType: PreviousViewType = .mapView
  }

  enum Action: Equatable, BindableAction {
    case dismiss
    case onApear
    case submitText
    case fetchRecentSearchWords
    case clearText
    case requestSearchPlace(String)
    case deleteRecentSearchWord(Int)
    case binding(BindingAction<State>)
    case recentSearchWordsResponse(TaskResult<[SearchWordResponseDTO]>)
    case tappedRecentSearchWord(String)
  }

  @Dependency(\.searchWordClient) private var searchWordClient

  var body: some ReducerProtocolOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .clearText:
        state.searchText = ""
        state.currentBodyType = .recentSearchListView
        return .none

      case .tappedRecentSearchWord(let recentWord):
        return .send(.requestSearchPlace(recentWord))

      case .binding(\.$searchText):
        if state.searchText.isEmpty {
          state.currentBodyType = .recentSearchListView
        } else {
          state.currentBodyType = .searchResultListView
        }
        return .none

      case .deleteRecentSearchWord(let index):
        let id = state.recentSearchKeyWordList[index].searchWordId
        return .run { send in
          try await searchWordClient.deleteRecentSearchWord(id: id)
          await send(.fetchRecentSearchWords)
        } catch: { error, send in
          debugPrint(error)
        }

      case .recentSearchWordsResponse(let result):
        switch result {
        case .success(let recentSearchWords):
          state.recentSearchKeyWordList = recentSearchWords
          return .none

        case .failure(let error):
          state.recentSearchKeyWordList = []
          debugPrint(error)
          return .none
        }

      case .fetchRecentSearchWords:
        return .run { send in
          let result = await TaskResult {
            try await searchWordClient.fetchRecentSearchWords()
          }
          return await send(.recentSearchWordsResponse(result))
        }

      case .submitText:
        return .send(.requestSearchPlace(state.searchText))

      case .dismiss:
        state.searchText = ""
        state.cafeList.removeAll()
        state.stationList.removeAll()
        state.recentSearchKeyWordList.removeAll()
        return .none

      case .onApear:
        state.currentBodyType = .recentSearchListView
        return .send(.fetchRecentSearchWords)

      default:
        return .none
      }
    }
  }
}
