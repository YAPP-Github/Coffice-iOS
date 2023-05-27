//
//  HomeCore.swift
//  Home
//
//  Created by Min Min on 2023/05/07.
//

import ComposableArchitecture

struct Home: ReducerProtocol {
  struct State: Equatable {
    let title = "Home"
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
//    case onAppear
    case getCoffees
    case pushLoginView
  }

  @Dependency(\.apiClient) private var apiClient

  var body: some ReducerProtocolOf<Home> {
    Reduce { _, action in
      switch action {
      default:
        return .none
      }
    }
  }
}
