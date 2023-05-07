//
//  ThirdCore.swift
//  YappProject
//
//  Created by Min Min on 2023/05/07.
//

import ComposableArchitecture

struct Third: ReducerProtocol {
  struct State: Equatable {
    let title: String = "This is ThirdView"
  }

  enum Action: Equatable {
    case onAppear
    case dismiss
  }

  var body: some ReducerProtocol<State, Action> {
    Reduce { _, action in
      switch action {
      case .onAppear:
        debugPrint("ThirdView onAppear Event")
        return .none

      case .dismiss:
        return .none
      }
    }
  }
}
