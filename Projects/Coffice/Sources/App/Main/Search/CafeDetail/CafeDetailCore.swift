//
//  CafeDetailCore.swift
//  coffice
//
//  Created by Min Min on 2023/06/24.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import Foundation

struct CafeDetail: ReducerProtocol {
  struct State: Equatable {
    @BindingState var toastViewMessage: String?
    var headerViewState: CafeDetailHeaderReducer.State = .init()
    var subInfoViewState: CafeDetailSubInfoReducer.State = .init()
    var menuViewState: CafeDetailMenuReducer.State = .init()

    var cafeId: Int
    var cafe: Cafe?
  }

  enum Action: Equatable, BindableAction {
    case binding(BindingAction<State>)
    case onAppear
    case placeResponse(cafe: Cafe)
    case popView
    case presentToastView(message: String)
    case fetchPlace

    // MARK: Cafe Detail Header
    case cafeDetailHeaderAction(CafeDetailHeaderReducer.Action)

    // MARK: Cafe Detail Sub Info
    case cafeDetailSubInfoAction(CafeDetailSubInfoReducer.Action)

    // MARK: Cafe Detail Menu
    case cafeDetailMenuAction(CafeDetailMenuReducer.Action)
  }

  @Dependency(\.placeAPIClient) private var placeAPIClient

  var body: some ReducerProtocolOf<CafeDetail> {
    BindingReducer()

    Scope(
      state: \.headerViewState,
      action: /Action.cafeDetailHeaderAction,
      child: {
        CafeDetailHeaderReducer()
      }
    )

    Scope(
      state: \.subInfoViewState,
      action: /Action.cafeDetailSubInfoAction,
      child: {
        CafeDetailSubInfoReducer()
      }
    )

    Scope(
      state: \.menuViewState,
      action: /Action.cafeDetailMenuAction,
      child: {
        CafeDetailMenuReducer()
      }
    )

    Reduce { state, action in
      switch action {
      case .onAppear:
        return .merge(
          EffectTask(value: .fetchPlace)
        )

      case .fetchPlace:
        return .run { [cafeId = state.cafeId] send in
          let cafe = try await placeAPIClient.fetchPlace(placeId: cafeId)
          await send(.placeResponse(cafe: cafe))
        } catch: { error, send in
          debugPrint(error)
        }

      case .placeResponse(let cafe):
        state.cafe = cafe
        return .merge(
          state.headerViewState.update(cafe: cafe).map(Action.cafeDetailHeaderAction),
          state.subInfoViewState.update(cafe: cafe).map(Action.cafeDetailSubInfoAction),
          state.menuViewState.update(cafe: cafe).map(Action.cafeDetailMenuAction)
        )

      case .presentToastView(let message):
        state.toastViewMessage = message
        return .none

        // MARK: Cafe Detail Header
      case .cafeDetailHeaderAction(.delegate(let action)):
        switch action {
        case .presentToastView(message: let message):
          return EffectTask(value: .presentToastView(message: message))
        case .fetchPlace:
          return EffectTask(value: .fetchPlace)
        case .updateBookmarkedState(let isBookmarked):
          state.cafe?.isBookmarked = isBookmarked
          return .none
        }

        // MARK: Cafe Detail Menu
      case .cafeDetailMenuAction(.delegate(.presentToastView(let message))):
        return EffectTask(value: .presentToastView(message: message))

      default:
        return .none
      }
    }
  }
}
