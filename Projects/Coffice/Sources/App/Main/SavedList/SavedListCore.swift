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
  }

  enum Action: Equatable {
    case onAppear
    case onDisappear
    case fetchMyPlaces
    case bookmarkButtonTapped(cafe: Cafe)
    case bookmarkedCafeResponse(cafes: [Cafe])
    case deleteCafesFromBookmark
    case pushCafeDetail(cafeId: Int)
  }

  @Dependency(\.bookmarkClient) private var bookmarkClient

  var body: some ReducerOf<SavedList> {
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
          await send(
            .bookmarkedCafeResponse(cafes: bookmarkedCafes)
          )
        } catch: { error, send in
          debugPrint(error)
        }

      case .bookmarkButtonTapped(let cafe):
        if let index = state.cafes.firstIndex(of: cafe) {
          state.cafes[index].isBookmarked.toggle()
        }
        return .none

      case .bookmarkedCafeResponse(let cafes):
        state.cafes = cafes
        state.didFetchComplete = true
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
