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
    case secondActive(Bool)
    case modalPresented(Bool)
    case second(Second.Action)
    case modal(Modal.Action)
    case getCoffees
    case getCoffeesResponse(TaskResult<CoffeeResponse>)
  }

  @Dependency(\.apiClient) private var apiClient

  var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
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

      case .getCoffees:
        // TODO: API 요청 테스트용 코드로 정리 필요
        return .run { send in
          let response = try await apiClient.getCoffees()
          await send(.getCoffeesResponse(.success(response)))
        } catch: { error, send in
          await send(.getCoffeesResponse(.failure(error)))
        }

      case .getCoffeesResponse(let taskResult):
        switch taskResult {
        case .success(let response):
          state.coffeeResponse = response
        case .failure(let error):
          debugPrint(error)
        }
        return .none

      default:
        return .none
      }
    }
  }
}
