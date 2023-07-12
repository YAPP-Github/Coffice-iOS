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
    var cafeId: Int
    var cafe: Cafe?
    var cafeTestImageAssets: [CofficeImages] = [
      CofficeAsset.Asset.cafeImage,
      CofficeAsset.Asset.userProfile40px,
      CofficeAsset.Asset.errorWarningFill40px
    ]

    let subMenuTypes = SubMenuType.allCases
    var subMenuViewStates: [SubMenusViewState] = SubMenuType.allCases
      .map { SubMenusViewState.init(subMenuType: $0, isSelected: $0 == .detailInfo) }
    var subPrimaryInfoViewStates: [SubPrimaryInfoViewState] = SubPrimaryInfoType.allCases
      .map(SubPrimaryInfoViewState.init)
    var subSecondaryInfoViewStates: [SubSecondaryInfoViewState] = SubSecondaryInfoType.allCases
      .map(SubSecondaryInfoViewState.init)
    var userReviewCellViewStates: [UserReviewCellViewState] = []
    var userReviewHeaderTitle: String {
      return "리뷰 \(userReviewCellViewStates.count)"
    }

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

    let imagePageViewHeight: CGFloat = 346.0
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
    var runningTimeDetailInfoArrowImageAsset: CofficeImages {
      return needToPresentRunningTimeDetailInfo
      ? CofficeAsset.Asset.arrowDropUpLine24px
      : CofficeAsset.Asset.arrowDropDownLine24px
    }
  }

  enum Action: Equatable {
    case onAppear
    case placeResponse(cafe: Cafe)
    case popView
    case subMenuTapped(State.SubMenuType)
    case toggleToPresentTextForTest
    case infoGuideButtonTapped(CafeFilter.GuideType)
    case presentBubbleMessageView(BubbleMessage.State)
    case presentCafeReviewWriteView
  }

  @Dependency(\.placeAPIClient) private var placeAPIClient

  var body: some ReducerProtocolOf<CafeSearchDetail> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        return .run { [cafeId = state.cafeId] send in
          let cafe = try await placeAPIClient.fetchPlace(placeId: cafeId)
          await send(.placeResponse(cafe: cafe))
        } catch: { error, send in
          debugPrint(error)
        }

      case .placeResponse(let cafe):
        state.cafe = cafe
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

      case .infoGuideButtonTapped(let guideType):
        return EffectTask(
          value: .presentBubbleMessageView(
            .init(guideType: guideType)
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
  struct UserReviewCellViewState: Equatable, Identifiable {
    let id = UUID()
    let userName: String
    let date: Date
    let content: String
    let tagTypes: [ReviewTagType]

    var dateDescription: String {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "M.dd E"
      return dateFormatter.string(from: date)
    }
  }

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
        return "🔌 콘센트 넉넉해요"
      case .fastWifi:
        return "📶 와이파이 빨라요"
      case .quiet:
        return "🔊 조용해요"
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

    var guideType: CafeFilter.GuideType {
      switch type {
      case .outletState: return .outletState
      case .spaceSize: return .spaceSize
      case .groupSeat: return .groupSeat
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
    var foregroundColorAsset: CofficeColors {
      isSelected ? CofficeAsset.Colors.grayScale9 : CofficeAsset.Colors.grayScale5
    }

    var bottomBorderColorAsset: CofficeColors {
      isSelected ? CofficeAsset.Colors.grayScale9 : CofficeAsset.Colors.grayScale1
    }

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
