//
//  CafeSearchView.swift
//  coffice
//
//  Created by sehooon on 2023/06/27.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct CafeSearchListView: View {
  let store: StoreOf<CafeSearchListCore>

  var body: some View {
    WithViewStore(store) { viewStore in
        VStack {
          header
          cafeListView
        }
    }
    .navigationBarBackButtonHidden(true)
  }
}

extension CafeSearchListView {
  var header: some View {
    VStack(spacing: 0) {
      HStack {
        Button {
        } label: {
          Text("지도")
        }
        .padding(.leading)
        searchTextField
      }
      orderFilterView
    }
  }
  var cafeListView: some View {
    ScrollView {
      ForEach(0...10, id: \.self) { _ in
        CafeCellView()
          .padding(.horizontal)
      }
    }
  }
  var searchTextField: some View {
    ZStack {
      TextField(
        "🔍  지역, 지하철로 검색",
        text: .constant("")
      )
      .frame(height: 35)
      .padding(.leading, 5)
      .padding(.trailing, 25)
      .overlay {
        RoundedRectangle(cornerRadius: 5)
          .stroke(.gray, lineWidth: 1)
      }
      .onSubmit {
      }
      HStack {
        Spacer()
        Button {

        } label: {
          Image(systemName: "xmark.circle.fill")
            .foregroundColor(.gray)
            .padding(.trailing, 5)
        }
      }
    }
    .padding(.horizontal, 16)
  }
  var orderFilterView: some View {
    WithViewStore(store) { viewStore in
      ScrollView(.horizontal) {
        HStack(spacing: 8) {
          ForEach(viewStore.filterOrders, id: \.self) { order in
            Button {
              viewStore.send(.filterButtonTapped(order))
            } label: {
              Text(order.titleName)
                .font(.subheadline)
                .foregroundColor(.black)
                .lineLimit(1)
                .padding(EdgeInsets(top: 7, leading: 12, bottom: 7, trailing: 12))
                .overlay {
                  RoundedRectangle(cornerRadius: 20)
                    .stroke(.gray, lineWidth: 1)
                }
                .frame(height: 60)
            }
          }
        }
        .padding(.horizontal, 16)
      }
    }
  }
}
