//
//  CafeSearchListCell.swift
//  coffice
//
//  Created by 천수현 on 2023/07/03.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation

import ComposableArchitecture
import SwiftUI

struct CafeSearchListCell: View {
  let store: StoreOf<CafeSearchListCore>

  var body: some View {
    WithViewStore(store) { viewStore in
      CardView(viewType: .listCell)
    }
  }
}

struct CafeSearchListCell_Previews: PreviewProvider {
  static var previews: some View {
    CafeSearchListCell(
      store: .init(
        initialState: .init(),
        reducer: CafeSearchListCore()
      )
    )
  }
}
