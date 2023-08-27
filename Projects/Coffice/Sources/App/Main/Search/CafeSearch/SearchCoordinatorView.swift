//
//  SearchCoordinatorView.swift
//  Cafe
//
//  Created by MinKyeongTae on 2023/05/29.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture
import SwiftUI
import TCACoordinators

struct SearchCoordinatorView: View {
  let store: StoreOf<SearchCoordinator>

  var body: some View {
    TCARouter(store) { screen in
      SwitchStore(screen) { state in
        switch state {
        case .cafeMap:
          CaseLet(
            /SearchScreen.State.cafeMap,
             action: SearchScreen.Action.cafeMap,
             then: CafeMapView.init
          )
        case .cafeSearchList:
          CaseLet(
            /SearchScreen.State.cafeSearchList,
             action: SearchScreen.Action.cafeSearchList,
             then: CafeSearchListView.init
          )
        case .cafeSearchDetail:
          CaseLet(
            /SearchScreen.State.cafeSearchDetail,
             action: SearchScreen.Action.cafeSearchDetail,
             then: CafeDetailView.init
          )
        case .cafeReviewWrite:
          CaseLet(
            /SearchScreen.State.cafeReviewWrite,
             action: SearchScreen.Action.cafeReviewWrite,
             then: CafeReviewWriteView.init
          )
        }
      }
    }
  }
}

struct SearchCoordinatorView_Previews: PreviewProvider {
  static var previews: some View {
    SearchCoordinatorView(
      store: .init(
        initialState: .initialState,
        reducer: {
          SearchCoordinator()
        }
      )
    )
  }
}
