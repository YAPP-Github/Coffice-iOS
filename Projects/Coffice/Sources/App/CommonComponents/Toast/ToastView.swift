//
//  ToastView.swift
//  coffice
//
//  Created by 천수현 on 2023/07/01.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import SwiftUI

struct ToastView: View {
  let title: String
  let image: CofficeImages?
  let config: ToastConfiguration

  var body: some View {
    VStack {
      Spacer()
      HStack {
        if let image {
          image.swiftUIImage
            .renderingMode(.template)
            .foregroundColor(CofficeAsset.Colors.grayScale1.swiftUIColor)
        }
        Text(title)
          .multilineTextAlignment(.center)
          .foregroundColor(config.textColor)
          .applyCofficeFont(font: config.font)
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 13)
      .background(config.backgroundColor)
      .cornerRadius(8)
    }
    .padding(.bottom, 100)
  }
}

struct ToastView_Previews: PreviewProvider {
  static var previews: some View {
    ToastView(
      title: "장소가 저장되었습니다.",
      image: CofficeAsset.Asset.checkboxCircleFill18px,
      config: ToastConfiguration.default
    )
  }
}
