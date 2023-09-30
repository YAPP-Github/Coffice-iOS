//
//  SavedListCore.swift
//  Cafe
//
//  Created by MinKyeongTae on 2023/05/29.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture

struct SavedList: Reducer {

  struct State: Equatable {
    let title = "저장 리스트"
    var cafes: [Cafe] = []
    var unBookmarkedCafeIds: [Int] {
      return cafes.filter { $0.isBookmarked.isFalse }.map { $0.placeId }
    }
    var didFetchComplete: Bool = false
    var shouldShowEmptyListReplaceView: Bool {
      return didFetchComplete && cafes.isEmpty
    }

    // MARK: Toast View
    @BindingState var toastMessage: String?
    let bookmarkFinishedMessage = "장소가 저장되었습니다."
  }

  enum Action: Equatable, BindableAction {
    case binding(BindingAction<SavedList.State>)
    case onAppear
    case onDisappear
    case fetchMyPlaces
    case bookmarkButtonTapped(cafe: Cafe)
    case bookmarkedCafeResult(TaskResult<[Cafe]>)
    case deleteCafesFromBookmark
    case pushCafeDetail(cafeId: Int)
  }

  @Dependency(\.bookmarkClient) private var bookmarkClient

  var body: some ReducerOf<SavedList> {
    BindingReducer()

    Reduce { state, action in
      switch action {
      case .onAppear:
        return .send(.fetchMyPlaces)

      case .onDisappear:
        return .run { send in
          await send(.deleteCafesFromBookmark)
        }

      case .fetchMyPlaces:
        return .run { send in
          let bookmarkedCafes = try await bookmarkClient.fetchMyPlaces()
          await send(.bookmarkedCafeResult(.success(bookmarkedCafes)))
        } catch: { error, send in
          await send(.bookmarkedCafeResult(.failure(error)))
        }

      case .bookmarkButtonTapped(let cafe):
        if let index = state.cafes.firstIndex(of: cafe) {
          state.cafes[index].isBookmarked.toggle()
          if state.cafes[index].isBookmarked {
            state.toastMessage = state.bookmarkFinishedMessage
          }
        }
        return .none

      case .bookmarkedCafeResult(let result):
        switch result {
        case .success(let cafes):
          state.cafes = cafes
          state.didFetchComplete = true
        case .failure(let error):
          debugPrint(error)
        }
        return .none

      case .deleteCafesFromBookmark:
        return .run { [unBookmarkedCafeIds = state.unBookmarkedCafeIds] send in
          try await bookmarkClient.deleteMyPlaces(placeIds: unBookmarkedCafeIds)
        } catch: { error, send in
          debugPrint(error)
        }

      default:
        return .none
      }
    }
  }
}
