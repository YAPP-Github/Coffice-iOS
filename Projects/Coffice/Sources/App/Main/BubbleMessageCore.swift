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
    let title: String
    let subTitle: String
    let subInfoViewStates: [SubInfoViewState]
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
    .init(
      title: "콘센트",
      subTitle: "좌석대비 콘센트 비율",
      subInfoViewStates: [
        .init(iconImage: CofficeAsset.Asset.close40px, title: "넉넉:", description: "80% 이상"),
        .init(iconImage: CofficeAsset.Asset.close40px, title: "보통:", description: "30% ~ 80%"),
        .init(iconImage: CofficeAsset.Asset.close40px, title: "부족:", description: "30% 미만")
      ]
    )
  }
}
