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
    
    var thirdState: Third.State?
    var isThirdPresented: Bool {
      thirdState != nil
    }
  }
  
  enum Action: Equatable, BindableAction {
    case binding(BindingAction<YappProject.State>)
    case onAppear
    case secondActive(Bool)
    case thirdPresented(Bool)
    case second(Second.Action)
    case third(Third.Action)
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

      case .second(let action):
        switch action {
        case .onAppear:
          break
        }
        return .none

      case .thirdPresented(let isPresented):
        if isPresented {
          state.thirdState = .init()
        } else {
          state.thirdState = nil
        }
        return .none

      case .third(let action):
        switch action {
        case .onAppear:
          break
          
        case .dismiss:
          return EffectTask(value: .thirdPresented(false))
        }
        return .none
      }
    }
    .ifLet(\.secondState, action: /Action.second) {
      Second()
    }
    .ifLet(\.thirdState, action: /Action.third) {
      Third()
    }
  }
}
