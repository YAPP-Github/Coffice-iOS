//
//  CafeTagTextView.swift
//  coffice
//
//  Created by sehooon on 2023/07/24.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import SwiftUI

struct CafeTagTextView: View {
  let text: String

  var body: some View {
    if text.isNotEmpty {
      Text(text)
        .foregroundColor(CofficeAsset.Colors.grayScale7.swiftUIColor)
        .applyCofficeFont(font: .body2Medium)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
          RoundedRectangle(cornerRadius: 4)
            .stroke(
              CofficeAsset.Colors.grayScale3.swiftUIColor,
              lineWidth: 1
            )
        )
    } else {
      EmptyView()
    }
  }
}

struct CafeTagTextView_Previews: PreviewProvider {
  static var previews: some View {
    CafeTagTextView(text: "")
  }
}
