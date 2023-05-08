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
  }

  enum Action: Equatable {
    case onAppear
    case thirdActive(Bool)
    case third(Third.Action)
  }

  var body: some ReducerProtocol<State, Action> {
    Reduce { _, action in
      switch action {
      case .onAppear:
        debugPrint("SecondView onAppear Event")
        return .none

      default:
        return .none
      }
    }
  }
}
