//
//  SavedListCore.swift
//  Cafe
//
//  Created by MinKyeongTae on 2023/05/29.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture

struct SavedList: ReducerProtocol {
  struct BookmarkCafe: Hashable {
    let cafeData: Cafe
    var isBookmarked: Bool
  }

  struct State: Equatable {
    let title = "저장 리스트"
    var cafes: [BookmarkCafe] = []
    var unBookmarkedCafeIds: [Int] {
      return cafes.filter { $0.isBookmarked.isFalse }.map { $0.cafeData.placeId }
    }
    var didFetchComplete: Bool = false
  }

  enum Action: Equatable {
    case onAppear
    case onDisappear
    case bookmarkButtonTapped(cafe: BookmarkCafe)
    case bookmarkedCafeResponse(cafes: [BookmarkCafe])
    case deleteCafesFromBookmark
  }

  @Dependency(\.bookmarkClient) private var bookmarkClient

  var body: some ReducerProtocolOf<SavedList> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        return .run { send in
          let bookmarkedCafes = try await bookmarkClient.fetchMyPlaces()
          await send(
            .bookmarkedCafeResponse(cafes: bookmarkedCafes.map { BookmarkCafe(cafeData: $0, isBookmarked: true)})
          )
        } catch: { error, send in
          debugPrint(error)
        }

      case .onDisappear:
        return .run { send in
          await send(.deleteCafesFromBookmark)
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
      }
    }
  }
}
