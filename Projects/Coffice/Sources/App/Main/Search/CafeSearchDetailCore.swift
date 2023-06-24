//
//  CafeSearchDetailCore.swift
//  coffice
//
//  Created by Min Min on 2023/06/24.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import Foundation

struct CafeSearchDetail: ReducerProtocol {
  enum SubMenuType: CaseIterable {
    case home
    case detailInfo
    case review

    var title: String {
      switch self {
      case .home: return "홈"
      case .detailInfo: return "세부정보"
      case .review: return "리뷰"
      }
    }
  }

  struct State: Equatable {
    let title = "CafeSearchDetail"
    let subMenus = SubMenuType.allCases
    var selectedSubMenuType: SubMenuType = .home
    var homeMenuViewHeight: CGFloat = 300.0
  }

  enum Action: Equatable {
    case onAppear
    case subMenuTapped(SubMenuType)
    case updateHomeMenuViewHeight
  }

  @Dependency(\.apiClient) private var apiClient

  var body: some ReducerProtocolOf<CafeSearchDetail> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        return .none

      case .subMenuTapped(let menuType):
        state.selectedSubMenuType = menuType
        return .none

      case .updateHomeMenuViewHeight:
        state.homeMenuViewHeight = 500
        return .none
      }
    }
  }
}
