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

  enum ViewType {
    case cardView
    case listCell
  }

  var body: some View {
    WithViewStore(store) { viewStore in
      CardView(viewType: .cardView)
    }
  }
}

struct CafeCardView_Previews: PreviewProvider {
  static var previews: some View {
    CafeCardView(
      store: .init(
        initialState: .init(),
        reducer: CafeMapCore()
      )
    )
  }
}
