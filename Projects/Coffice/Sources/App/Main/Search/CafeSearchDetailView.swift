//
//  CafeSearchDetailView.swift
//  coffice
//
//  Created by Min Min on 2023/06/24.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct CafeSearchDetailView: View {
  private let store: StoreOf<CafeSearchDetail>

  init(store: StoreOf<CafeSearchDetail>) {
    self.store = store
  }

  var body: some View {
    mainView
  }

  var mainView: some View {
    WithViewStore(store) { viewStore in
      VStack(spacing: 0) {
        ScrollView(.vertical) {
          VStack(spacing: 0) {
            CafeSearchDetailHeaderView(store: store)
            CafeSearchDetailSubInfoView(store: store)
            CafeSearchDetailMenuView(store: store)
          }
          .padding(.bottom, 50)
        }
      }
      .navigationBarHidden(true)
      .ignoresSafeArea(.all, edges: .top)
      .overlay(alignment: .topLeading, content: {
        Button {
          viewStore.send(.popView)
        } label: {
          ZStack(alignment: .center) {
            Color.clear
              .frame(width: 40, height: 40)
            Image(systemName: "chevron.left")
              .resizable()
              .scaledToFit()
              .frame(height: 21)
              .tint(.white)
          }
          .padding(.top, 4)
          .padding(.leading, 8)
        }
      })
      .onAppear {
        viewStore.send(.onAppear)
      }
    }
  }
}

struct CafeSearchDetailView_Previews: PreviewProvider {
  static var previews: some View {
    CafeSearchDetailView(
      store: .init(
        initialState: .init(),
        reducer: CafeSearchDetail()
      )
    )
  }
}
