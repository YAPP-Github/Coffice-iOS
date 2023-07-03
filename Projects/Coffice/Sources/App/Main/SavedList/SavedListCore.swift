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
  }

  enum Action: Equatable {
    case onAppear
    case onDisappear
    case bookmarkButtonTapped(cafe: BookmarkCafe)
    case bookmarkedCafeResponse(cafes: [BookmarkCafe])
    case deleteCafefromBookmark(cafeId: Int)
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
        return .none

      case .bookmarkButtonTapped(let cafe):
        if let index = state.cafes.firstIndex(of: cafe) {
          state.cafes[index].isBookmarked.toggle()
        }
        return .none

      case .bookmarkedCafeResponse(let cafes):
        state.cafes = cafes
        return .none

      case .deleteCafefromBookmark(let cafeId):
        return .none
      }
    }
  }
}
