//
//  SavedListCoordinatorView.swift
//  Cafe
//
//  Created by MinKyeongTae on 2023/05/29.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture
import SwiftUI
import TCACoordinators

struct SavedListCoordinatorView: View {
  let store: StoreOf<SavedListCoordinator>

  var body: some View {
    TCARouter(store) { screen in
      SwitchStore(screen) { state in
        switch state {
        case .savedList:
          CaseLet(
            /SavedListScreen.State.savedList,
            action: SavedListScreen.Action.savedList,
            then: SavedListView.init
          )
        case .cafeSearchDetail:
          CaseLet(
            /SavedListScreen.State.cafeSearchDetail,
            action: SavedListScreen.Action.cafeSearchDetail,
            then: CafeDetailView.init
          )
        }
      }
    }
  }
}

struct SavedListCoordinatorView_Previews: PreviewProvider {
  static var previews: some View {
    SavedListCoordinatorView(
      store: .init(
        initialState: .initialState,
        reducer: {
          SavedListCoordinator()
        }
      )
    )
  }
}
