//
//  YappProjectCore.swift
//  YappProject
//
//  Created by Min Min on 2023/05/07.
//

import ComposableArchitecture

struct YappProject: ReducerProtocol {
  struct State: Equatable {
    let title = "YappProject"
    var isSplashView = false
  }

  enum Action: Equatable {
    case onAppear
    case secondActive(Bool)
    case modalPresented(Bool)
    case second(Second.Action)
    case modal(Modal.Action)
  }

  var body: some ReducerProtocol<State, Action> {
    Reduce { _, action in
      switch action {
      case .onAppear:
        return .none

      case .second(.onAppear):
        return .none

      case .modal(let action):
        switch action {
        case .onAppear:
          break

        case .dismiss:
          return EffectTask(value: .modalPresented(false))
        }
        return .none

      default:
        return .none
      }
    }
  }
}
