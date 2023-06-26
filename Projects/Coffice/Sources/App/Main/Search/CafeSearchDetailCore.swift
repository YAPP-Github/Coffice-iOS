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
  struct State: Equatable {
    let title = "CafeSearchDetail"

    let subMenuTypes = SubMenuType.allCases
    var subMenuViewStates: [SubMenusViewState] = SubMenuType.allCases
      .map { SubMenusViewState.init(subMenuType: $0, isSelected: $0 == .detailInfo) }
    var subPrimaryInfoViewStates: [SubPrimaryInfoViewState] = SubPrimaryInfoType.allCases
      .map(SubPrimaryInfoViewState.init)
    var subSecondaryInfoViewStates: [SubSecondaryInfoViewState] = SubSecondaryInfoType.allCases
      .map(SubSecondaryInfoViewState.init)

    var selectedSubMenuType: SubMenuType = .detailInfo {
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
                              화 09:00 - 21:00
                              수 09:00 - 21:00
                              목 09:00 - 21:00
                              금 정기휴무 (매주 금요일)
                              토 09:00 - 21:00
                              일 09:00 - 21:00
                              """
    var runningTimeDetailInfo = ""
    var needToPresentRunningTimeDetailInfo = false
  }

  enum Action: Equatable {
    case onAppear
    case popView
    case subMenuTapped(State.SubMenuType)
    case toggleToPresentTextForTest
    case infoGuideButtonTapped
    case presentBubbleMessageView(MainCoordinator.State.BubbleMessageViewState)
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

      case .toggleToPresentTextForTest:
        state.needToPresentRunningTimeDetailInfo.toggle()

        if state.needToPresentRunningTimeDetailInfo {
          state.runningTimeDetailInfo = state.openTimeDescription
        } else {
          state.runningTimeDetailInfo = ""
        }
        return .none

      case .infoGuideButtonTapped:
        // TODO: 선택한 버튼에 맞게 맞춤형 정보가 있는 말풍선 표출 필요
        return EffectTask(
          value: .presentBubbleMessageView(
            .init(
              title: "콘센트",
              subTitle: "좌석대비 콘센트 비율",
              subInfoViewStates: [
                .init(iconImage: CofficeAsset.Asset.close40px, title: "넉넉:", description: "80% 이상"),
                .init(iconImage: CofficeAsset.Asset.close40px, title: "보통:", description: "30% ~ 80%"),
                .init(iconImage: CofficeAsset.Asset.close40px, title: "부족:", description: "30% 미만")
              ]
            )
          )
        )

      default:
        return .none
      }
    }
  }
}

// MARK: - Sub Views State

extension CafeSearchDetail.State {
  enum SubMenuType: CaseIterable {
    case detailInfo
    case review
  }

  enum SubPrimaryInfoType: CaseIterable {
    case outletState
    case spaceSize
    case groupSeat
  }

  enum SubSecondaryInfoType: CaseIterable {
    case food
    case toilet
    case beverage
    case price
    case congestion
  }

  enum CongestionLevel {
    case low
    case middle
    case high
  }

  enum ReviewTagType: CaseIterable {
    case enoughOutlets
    case fastWifi
    case quiet

    var title: String {
      switch self {
      case .enoughOutlets:
        return "콘센트 넉넉해요"
      case .fastWifi:
        return "와이파이 빨라요"
      case .quiet:
        return "조용해요"
      }
    }

    var iconName: String {
      switch self {
      case .enoughOutlets:
        return "power"
      case .fastWifi:
        return "wifi"
      case .quiet:
        return "speaker.wave.1"
      }
    }
  }

  struct SubPrimaryInfoViewState: Identifiable, Equatable {
    let id = UUID()
    let type: SubPrimaryInfoType
    var description = "-"

    init(type: SubPrimaryInfoType) {
      self.type = type

      description = "-"

      switch type {
      case .outletState:
        description = "넉넉"
      case .spaceSize:
        description = "대형"
      case .groupSeat:
        description = "있음"
      }
    }

    var title: String {
      switch type {
      case .outletState: return "콘센트"
      case .spaceSize: return "공간 크기"
      case .groupSeat: return "단체석"
      }
    }

    var iconName: String {
      switch type {
      case .outletState: return "power"
      case .spaceSize: return "house"
      case .groupSeat: return "person"
      }
    }
  }

  struct SubSecondaryInfoViewState: Identifiable, Equatable {
    let id = UUID()
    let type: SubSecondaryInfoType
    var description = "-"
    var congestionLevel: CongestionLevel

    init(type: SubSecondaryInfoType) {
      self.type = type

      congestionLevel = .high
      description = "-"

      switch type {
      case .food:
        description = "디저트 / 식사가능"
      case .toilet:
        description = "실내 / 남녀개별"
      case .beverage:
        description = "디카페인 / 두유"
      case .price:
        description = "아메리카노 4000원~"
      case .congestion:
        description = "평일 오후"
      }
    }

    var title: String {
      switch type {
      case .food: return "푸드"
      case .toilet: return "화장실"
      case .beverage: return "음료"
      case .price: return "가격대"
      case .congestion: return "혼잡도"
      }
    }

    var congestionDescription: String {
      switch congestionLevel {
      case .low: return "여유"
      case .middle: return "보통"
      case .high: return "혼잡"
      }
    }
  }

  struct SubMenusViewState: Identifiable, Equatable {
    let id = UUID()
    let type: SubMenuType
    let isSelected: Bool

    init(subMenuType: SubMenuType, isSelected: Bool = false) {
      self.type = subMenuType
      self.isSelected = isSelected
    }

    var title: String {
      switch type {
      case .detailInfo: return "세부정보"
      case .review: return "리뷰"
      }
    }
  }
}
