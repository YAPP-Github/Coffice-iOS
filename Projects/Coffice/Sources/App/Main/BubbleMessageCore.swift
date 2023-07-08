//
//  BubbleMessageCore.swift
//  coffice
//
//  Created by MinKyeongTae on 2023/06/27.
//  Copyright (c) 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import Foundation

struct BubbleMessage: ReducerProtocol {
  struct State: Equatable {
    let guideType: CafeFilter.GuideType

    var title: String {
      switch guideType {
      case .outletState: return "콘센트"
      case .spaceSize: return "공간크기"
      case .groupSeat: return "단체석"
      }
    }

    var subTitle: String {
      switch guideType {
      case .outletState: return "좌석대비 콘센트 비율"
      case .spaceSize: return "테이블 기준 크기"
      case .groupSeat: return "단체석 기준"
      }
    }

    var subInfoViewStates: [SubInfoViewState] {
      switch guideType {
      case .outletState:
        return [
          .init(iconImage: CofficeAsset.Asset.close40px, title: "넉넉:", description: "80% 이상"),
          .init(iconImage: CofficeAsset.Asset.close40px, title: "보통:", description: "30% ~ 80%"),
          .init(iconImage: CofficeAsset.Asset.close40px, title: "부족:", description: "30% 미만")
        ]
      case .spaceSize:
        return [
          .init(iconImage: CofficeAsset.Asset.close40px, title: "대형:", description: "테이블 15개 이상"),
          .init(iconImage: CofficeAsset.Asset.close40px, title: "보통:", description: "테이블 6 ~ 14개"),
          .init(iconImage: CofficeAsset.Asset.close40px, title: "부족:", description: "테이블 5개 이하")
        ]
      case .groupSeat:
        return [
          .init(iconImage: CofficeAsset.Asset.close40px, title: "단체석:", description: "5인 테이블")
        ]
      }
    }
  }

  struct SubInfoViewState: Equatable, Identifiable {
    let id = UUID()
    let iconImage: CofficeImages
    let title: String
    let description: String
  }

  enum Action: Equatable {
    case onAppear
  }

  var body: some ReducerProtocolOf<BubbleMessage> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        return .none
      }
    }
  }
}

extension BubbleMessage.State {
  static var mock: Self {
    .init(guideType: .outletState)
  }
}
