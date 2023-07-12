//
//  PlaceCellView.swift
//  coffice
//
//  Created by sehooon on 2023/07/10.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import SwiftUI

struct PlaceCellView: View {
  var place: Cafe?
  var body: some View {
    HStack(spacing: 0) {
      VStack(alignment: .leading, spacing: 8) {
        Text(place?.name ?? "")
          .applyCofficeFont(font: .subtitleSemiBold)
        Text(place?.address?.address ?? "")
          .applyCofficeFont(font: .body1Medium)
          .foregroundColor(CofficeAsset.Colors.grayScale6.swiftUIColor)
      }
      Spacer()
    }
    .padding(EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20))
  }
}

struct PlaceCellView_Previews: PreviewProvider {
  static var previews: some View {
    PlaceCellView()
  }
}
