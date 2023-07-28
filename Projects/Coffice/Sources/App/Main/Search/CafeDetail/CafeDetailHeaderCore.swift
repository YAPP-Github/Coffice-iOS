//
//  CafeDetailHeaderCore.swift
//  coffice
//
//  Created by Min Min on 2023/07/27.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import Foundation

struct CafeDetailHeaderReducer: ReducerProtocol {
  struct State: Equatable {
    // MARK: Entity
    var cafe: Cafe?

    // MARK: Constant
    let bookmarkedMessage = "장소가 저장되었습니다."
    let imagePageViewHeight: CGFloat = 346.0

    mutating func update(cafe: Cafe?) -> EffectTask<Action> {
      self.cafe = cafe
      return .none
    }
  }

  enum Action: Equatable {
    case bookmarkButtonTapped
    case addMyPlace
    case addMyPlaceFinished
    case deleteMyPlace
    case delegate(Delegate)
  }

  enum Delegate: Equatable {
    case presentToastView(message: String)
    case fetchPlace
    case updateBookmarkedState(Bool)
  }

  @Dependency(\.bookmarkClient) private var bookmarkAPIClient

  var body: some ReducerProtocolOf<CafeDetailHeaderReducer> {
    Reduce { state, action in
      switch action {
      case .bookmarkButtonTapped:
        state.cafe?.isBookmarked.toggle()
        let isBookmarked = state.cafe?.isBookmarked ?? false

        if isBookmarked {
          return .merge(
            EffectTask(value: .delegate(.updateBookmarkedState(isBookmarked))),
            EffectTask(value: .addMyPlace)
          )
        } else {
          return .merge(
            EffectTask(value: .delegate(.updateBookmarkedState(isBookmarked))),
            EffectTask(value: .deleteMyPlace)
          )
        }

      case .addMyPlace:
        guard let placeId = state.cafe?.placeId
        else { return .none }

        return .run { send in
          try await bookmarkAPIClient.addMyPlace(placeId: placeId)
          await send(.addMyPlaceFinished)
        } catch: { error, send in
          debugPrint(error)
        }

      case .addMyPlaceFinished:
        let bookmarkedMessage = state.bookmarkedMessage

        return .merge(
          EffectTask(value: .delegate(.fetchPlace)),
          EffectTask(value: .delegate(.presentToastView(message: bookmarkedMessage)))
        )

      case .deleteMyPlace:
        guard let placeId = state.cafe?.placeId
        else { return .none }

        return .run { send in
          try await bookmarkAPIClient.deleteMyPlace(placeId: placeId)
          await send(.delegate(.fetchPlace))
        } catch: { error, send in
          debugPrint(error)
        }

      default:
        return .none
      }
    }
  }
}

// MARK: - Getter

extension CafeDetailHeaderReducer.State {
  var cafeName: String {
    cafe?.name ?? "-"
  }

  var cafeAddress: String {
    cafe?.address?.address ?? "-"
  }

  var openingStateDescription: String {
    cafe?.openingInformation?.isOpened ?? false
    ? "영업중" : "영업종료"
  }

  var todayRunningTimeDescription: String {
    cafe?.openingInformation?.quickFormattedString ?? "-"
  }

  var bookmarkButtonImage: CofficeImages {
    return cafe?.isBookmarked ?? false
    ? CofficeAsset.Asset.bookmarkFill40px
    : CofficeAsset.Asset.bookmarkLine40px
  }
}
