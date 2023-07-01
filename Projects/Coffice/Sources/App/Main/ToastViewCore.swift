//
//  ToastViewCore.swift
//  coffice
//
//  Created by 천수현 on 2023/07/01.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import Foundation
import SwiftUI

struct ToastViewReducer: ReducerProtocol {
  struct State: Equatable {
    let title: String
    let image: CofficeImages
    let config: Config
  }

  enum Action: Equatable {
    case onAppear
  }

  var body: some ReducerProtocolOf<ToastViewReducer> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        return .none
      }
    }
  }
}

extension ToastViewReducer.State {
  static var mock: Self {
    .init(
      title: "장소가 저장되었습니다.",
      image: CofficeAsset.Asset.checkboxCircleFill18px,
      config: Config.default
    )
  }
}

struct Config: Equatable {
  static let `default` = Config()
  let textColor: Color
  let font: CofficeFont
  let backgroundColor: Color
  let duration: TimeInterval

  init(
    textColor: Color = CofficeAsset.Colors.grayScale1.swiftUIColor,
    font: CofficeFont = .body1Medium,
    backgroundColor: Color = CofficeAsset.Colors.grayScale8.swiftUIColor,
    duration: TimeInterval = 2
  ) {
    self.textColor = textColor
    self.font = font
    self.backgroundColor = backgroundColor
    self.duration = duration
  }
}
