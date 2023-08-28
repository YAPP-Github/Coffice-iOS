//
//  CafeDetailHeaderCore.swift
//  coffice
//
//  Created by Min Min on 2023/07/27.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import Foundation

struct CafeDetailHeaderReducer: Reducer {
  struct State: Equatable {
    // MARK: Entity
    var cafe: Cafe?

    // MARK: Constant
    let bookmarkedMessage = "장소가 저장되었습니다."
    let imagePageViewHeight: CGFloat = 346.0

    mutating func update(cafe: Cafe?) -> Effect<Action> {
      self.cafe = cafe
      return .none
    }

    var urlToShare: URL? {
      guard let latitude = cafe?.latitude, let longitude = cafe?.longitude
      else { return nil }
      let longitudeInEPSG3857 = (longitude * 20037508.34 / 180)
      let latitudeInEPSG3857 = (log(tan((90 + latitude) * Double.pi / 360)) / (Double.pi / 180)) * (20037508.34 / 180)

      return URL(string: "https://map.naver.com/v5/?c=\(longitudeInEPSG3857),\(latitudeInEPSG3857),18,0,0,0,dh")
    }
  }

  enum Action: Equatable {
    case bookmarkButtonTapped
    case bookmarkResponse(isBookmarked: Bool)
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

  var body: some ReducerOf<CafeDetailHeaderReducer> {
    Reduce { state, action in
      switch action {
      case .bookmarkButtonTapped:
        state.cafe?.isBookmarked.toggle()
        let isBookmarked = state.cafe?.isBookmarked ?? false

        return .send(.bookmarkResponse(isBookmarked: isBookmarked))

      case .bookmarkResponse(let isBookmarked):
        if isBookmarked {
          return .merge(
            .send(.delegate(.updateBookmarkedState(isBookmarked))),
            .send(.addMyPlace)
          )
        } else {
          return .merge(
            .send(.delegate(.updateBookmarkedState(isBookmarked))),
            .send(.deleteMyPlace)
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
          .send(.delegate(.fetchPlace)),
          .send(.delegate(.presentToastView(message: bookmarkedMessage)))
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
