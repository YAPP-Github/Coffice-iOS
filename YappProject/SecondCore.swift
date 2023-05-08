//
//  SecondCore.swift
//  YappProject
//
//  Created by Min Min on 2023/05/07.
//

import ComposableArchitecture

struct Second: ReducerProtocol {
  struct State: Equatable {
    let title: String = "This is SecondView"
    var thirdState: Third.State?
    var isThirdActive: Bool {
      thirdState != nil
    }
  }

  enum Action: Equatable {
    case onAppear
    case thirdActive(Bool)
    case third(Third.Action)
  }

  var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        debugPrint("SecondView onAppear Event")
        return .none

      case .thirdActive(let isActive):
        if isActive {
          state.thirdState = .init()
        } else {
          state.thirdState = nil
        }
        return .none

      default:
        return .none
      }
    }
    .ifLet(\.thirdState, action: /Action.third) {
      Third()
    }
  }
}
