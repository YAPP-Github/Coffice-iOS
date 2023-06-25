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

  struct SubMenusViewState: Identifiable, Equatable {
    let id = UUID()
    let subMenuType: SubMenuType
    let isSelected: Bool

    init(subMenuType: SubMenuType, isSelected: Bool) {
      self.subMenuType = subMenuType
      self.isSelected = isSelected
    }
  }

  struct State: Equatable {
    let title = "CafeSearchDetail"
    let subMenuTypes = SubMenuType.allCases
    var subMenuViewStates: [SubMenusViewState] = []
    var selectedSubMenuType: SubMenuType = .home {
      didSet {
        subMenuViewStates = SubMenuType.allCases.map { subMenuType in
          SubMenusViewState(
            subMenuType: subMenuType,
            isSelected: subMenuType == selectedSubMenuType
          )
        }
      }
    }

    let homeMenuViewHeight: CGFloat = 100.0
    let openTimeDescription = """
                      월 09:00 - 21:00
                      화 09:00 - 21:00
                      수 09:00 - 21:00
                      목 09:00 - 21:00
                      금 정기휴무 (매주 금요일)
                      일 09:00 - 21:00
                      """
    var runningTimeDetailInfo = ""
    var needToPresentRunningTimeDetailInfo = false
  }

  enum Action: Equatable {
    case onAppear
    case popView
    case subMenuTapped(SubMenuType)
    case toggleToPresentTextForTest
  }

  @Dependency(\.apiClient) private var apiClient

  var body: some ReducerProtocolOf<CafeSearchDetail> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        state.selectedSubMenuType = .home
        return .none

      case .subMenuTapped(let menuType):
        state.selectedSubMenuType = menuType
        return .none

      case .toggleToPresentTextForTest:
        state.needToPresentRunningTimeDetailInfo.toggle()

        if state.needToPresentRunningTimeDetailInfo {
          state.runningTimeDetailInfo = state.openTimeDescription
        } else {
          state.runningTimeDetailInfo = ""
        }
        return .none

      default:
        return .none
      }
    }
  }
}
