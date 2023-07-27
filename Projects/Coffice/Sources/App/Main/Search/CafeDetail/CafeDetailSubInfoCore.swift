//
//  CafeDetailSubInfoCore.swift
//  coffice
//
//  Created by Min Min on 2023/07/27.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import Foundation

struct CafeDetailSubInfoReducer: ReducerProtocol {
  struct State: Equatable {
    @BindingState var bubbleMessageViewState: BubbleMessage.State?

    var cafe: Cafe?
    var updatedDate: Date?

    var subPrimaryInfoViewStates: [SubPrimaryInfoViewState] = []
      .map(SubPrimaryInfoViewState.init)
    var subSecondaryInfoViewStates: [SubSecondaryInfoViewState] = []

    var updatedDateDescription: String {
      guard let updatedDate else { return "-" }
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "M월 dd일 hh:mm 기준"
      return dateFormatter.string(from: updatedDate)
    }

    mutating func update(cafe: Cafe?) -> EffectTask<Action> {
      guard let cafe else { return .none }
      self.cafe = cafe
      subPrimaryInfoViewStates = [
        .init(type: .outletState(cafe.electricOutletLevel)),
        .init(type: .spaceSize(cafe.capacityLevel)),
        .init(type: .groupSeat(cafe.hasCommunalTable))
      ]
      subSecondaryInfoViewStates = State.SubSecondaryInfoType.allCases
        .map { State.SubSecondaryInfoViewState(cafe: cafe, type: $0) }
      return EffectTask(value: .updateLastModifiedDate)
    }
  }

  enum Action: Equatable, BindableAction {
    case binding(BindingAction<State>)
    case updateLastModifiedDate
    case infoGuideButtonTapped(CafeFilter.GuideType)
    case presentBubbleMessageView(BubbleMessage.State)
    case bubbleMessageAction(BubbleMessage.Action)
  }

  var body: some ReducerProtocolOf<Self> {
    BindingReducer()

    Reduce { state, action in
      switch action {
      case .updateLastModifiedDate:
        state.updatedDate = Date()
        return .none

      case .infoGuideButtonTapped(let guideType):
        return EffectTask(
          value: .presentBubbleMessageView(
            .init(guideType: guideType)
          )
        )

      case .presentBubbleMessageView(let viewState):
        state.bubbleMessageViewState = viewState
        return .none

      default:
        return .none
      }
    }
  }
}

extension CafeDetailSubInfoReducer.State {
  struct SubPrimaryInfoViewState: Identifiable, Equatable {
    let id = UUID()
    let type: SubPrimaryInfoType
    var description = "-"

    init(type: SubPrimaryInfoType) {
      self.type = type

      description = "-"

      switch type {
      case .outletState(let outletLevel):
        description = outletLevel.informationText
      case .spaceSize(let capacityLevel):
        description = capacityLevel.informationText
      case .groupSeat(let groupSeatLevel):
        description = groupSeatLevel.informationText
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
      case .outletState(let outletLevel): return outletLevel.iconName
      case .spaceSize(let capacityLevel): return capacityLevel.iconName
      case .groupSeat(let groupSeatLevel): return groupSeatLevel.iconName
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

    init(cafe: Cafe, type: SubSecondaryInfoType) {
      self.type = type

      congestionLevel = .high
      description = "-"

      switch type {
      case .food:
        let foodTypeTexts = cafe.foodTypes?.map(\.text) ?? []
        description = foodTypeTexts.isNotEmpty
        ? foodTypeTexts.joined(separator: "/")
        : "-"
      case .toilet:
        description = "-" // FIXME: 서버에서 안내려오는중 (화장실 정보)
      case .beverage:
        let drinkTypeTexts = cafe.drinkTypes?.map(\.text) ?? []
        description = drinkTypeTexts.isNotEmpty
        ? drinkTypeTexts.joined(separator: "/")
        : "-"
      case .price:
        description = "-" // FIXME: 서버에서 안내려오는중 (가격 정보)
      case .congestion:
        description = "-" // FIXME: 서버에서 요일별로 내려오는중인데 어떤 정보를 어떻게 띄워줘야할지 정리 필요
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
  }

  enum SubPrimaryInfoType: Hashable {
    case outletState(ElectricOutletLevel)
    case spaceSize(CapacityLevel)
    case groupSeat(CafeGroupSeatLevel)
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
}
