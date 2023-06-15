//
//  MyPageCore.swift
//  Cafe
//
//  Created by MinKyeongTae on 2023/05/26.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture
import Foundation

struct MyPage: ReducerProtocol {
  struct MenuItem: Equatable, Identifiable {
    let id = UUID()
    let menuType: MenuType

    var title: String {
      switch menuType {
      case .serviceTerms:
        return "서비스 이용 약관"
      case .openSources:
        return "오픈소스 라이브러리"
      case .devTest:
        return "개발자 테스트"
      }
    }
  }

  enum MenuType {
    case serviceTerms
    case openSources
    case devTest
  }

  struct State: Equatable {
    let title = "MyPage"
    let menuTypes: [MenuType] = [.serviceTerms, .openSources, .devTest]
    let menuItems: [MenuItem]

    init() {
      menuItems = menuTypes.map(MenuItem.init)
    }
  }

  enum Action: Equatable {
    case onAppear
    case menuClicked(MenuItem)
    case pushToServiceTermsView
    case pushToOpenSourcesView
    case pushToDevTestView
  }

  @Dependency(\.apiClient) private var apiClient

  var body: some ReducerProtocolOf<MyPage> {
    Reduce { _, action in
      switch action {
      case .onAppear:
        return .none

      case .menuClicked(let menuItem):
        switch menuItem.menuType {
        case .serviceTerms:
          return EffectTask(value: .pushToServiceTermsView)
        case .openSources:
          return EffectTask(value: .pushToOpenSourcesView)
        case .devTest:
          return EffectTask(value: .pushToDevTestView)
        }

      default:
        return .none
      }
    }
  }
}
