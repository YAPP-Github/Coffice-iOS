//
//  CafeReportView.swift
//  coffice
//
//  Created by Min Min on 11/2/23.
//  Copyright (c) 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct CafeReportView: View {
  let store: StoreOf<CafeReport>

  var body: some View {
    WithViewStore(
      store,
      observe: { $0 },
      content: { viewStore in
        VStack(spacing: 0) {

        }
        .onAppear {
          viewStore.send(.onAppear)
        }
      }
    )
  }
}

struct CafeReportView_Previews: PreviewProvider {
  static var previews: some View {
    CafeReportView(
      store: Store(initialState: CafeReport.State()) {
        CafeReport()
      }
    )
  }
}
