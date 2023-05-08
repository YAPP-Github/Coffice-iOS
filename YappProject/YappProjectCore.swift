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
    var secondState: Second.State?
    var isSecondActive: Bool {
      secondState != nil
    }

    var modalState: Modal.State?
    var isModalPresented: Bool {
      modalState != nil
    }
  }

  enum Action: Equatable, BindableAction {
    case binding(BindingAction<YappProject.State>)
    case onAppear
    case secondActive(Bool)
    case modalPresented(Bool)
    case second(Second.Action)
    case modal(Modal.Action)
  }

  var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .binding:
        return .none

      case .onAppear:
        return .none

      case .secondActive(let isActive):
        if isActive {
          state.secondState = .init()
        } else {
          state.secondState = nil
        }
        return .none

      case .second(.onAppear):
        return .none

      case .modalPresented(let isPresented):
        if isPresented {
          state.modalState = .init()
        } else {
          state.modalState = nil
        }
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
    .ifLet(\.secondState, action: /Action.second) {
      Second()
    }
    .ifLet(\.modalState, action: /Action.modal) {
      Modal()
    }
  }
}
