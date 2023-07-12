//
//  WaypointCellView.swift
//  coffice
//
//  Created by sehooon on 2023/07/10.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import SwiftUI

struct WaypointCellView: View {
  var waypoint: WayPoint?
  var body: some View {
    HStack(spacing: 0) {
      Text(waypoint?.name ?? "")
        .applyCofficeFont(font: .subtitleSemiBold)
        .foregroundColor(CofficeAsset.Colors.grayScale9.swiftUIColor)
        .lineLimit(1)
        Spacer()
    }
    .padding(EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20))
  }
}

struct WaypointCellView_Previews: PreviewProvider {
  static var previews: some View {
    WaypointCellView()
  }
}
