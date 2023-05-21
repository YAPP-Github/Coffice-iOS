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
    var coffeeResponse: CoffeeResponse?
    var coffeeDescription: String? {
      guard let coffeeResponse
      else { return nil }
      return coffeeResponse
        .map {
          """
          \($0.title)
          \($0.description)
          """
        }
        .joined(separator: "\n\n")
    }
  }

  enum Action: Equatable {
    case onAppear
    case getCoffees
  }

  @Dependency(\.apiClient) private var apiClient

  var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        return .none

      default:
        return .none
      }
    }
  }
}
