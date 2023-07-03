//
//  CafeCardView.swift
//  coffice
//
//  Created by sehooon on 2023/06/26.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct CafeCardView: View {
  let store: StoreOf<CafeMapCore>
  let cafe: Cafe

  enum ViewType {
    case cardView
    case listCell
  }

  var body: some View {
    WithViewStore(store) { viewStore in
      CardView(viewType: .cardView, cafe: cafe)
    }
  }
}

struct CafeCardView_Previews: PreviewProvider {
  static var previews: some View {
    CafeCardView(
      store: .init(
        initialState: .init(),
        reducer: CafeMapCore()
      ),
      cafe: Cafe.dummy
    )
  }
}
