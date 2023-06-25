//
//  CafeMapView.swift
//  Cafe
//
//  Created by sehooon on 2023/05/29.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture
import NMapsMap
import SwiftUI

struct CafeMapView: View {
  let store: StoreOf<CafeMapCore>
  var body: some View {
    WithViewStore(store) { viewStore in
      GeometryReader { geometry in
        ZStack {
          NaverMapView(viewStore: viewStore)
            .ignoresSafeArea()
          VStack(alignment: .trailing) {
            header
              .background(.white)
            floatingButtonView
            .padding()
            CafePreview()
              .frame(width: 350, height: 150)
              .position(
                x: geometry.size.width / 2,
                y: geometry.size.height / 2.7
              )
          }
          .navigationBarHidden(true)
        }
        .onAppear {
          viewStore.send(.requestLocationAuthorization)
        }
      }
      .ignoresSafeArea(.keyboard)
    }
  }
}

extension CafeMapView {
  var floatingButtonView: some View {
    WithViewStore(store) { viewStore in
      VStack(spacing: 10) {
        ForEach(viewStore.floatingButtons, id: \.self) { floatingButton in
          Button {
            viewStore.send(.floatingButtonTapped(floatingButton))
          } label: {
            Circle()
              .foregroundColor(.white)
              .shadow(color: .gray, radius: 2, x: 0, y: 2)
              .overlay {
                Image(systemName: floatingButton.image)
              }
              .frame(width: 50, height: 50)
          }
          .buttonStyle(.plain)
        }
      }
    }
  }

  var header: some View {
    WithViewStore(store) { viewStore in
      VStack(spacing: 0) {
        searchTextField
        orderFilterView
      }
    }
  }

  var searchTextField: some View {
    WithViewStore(store) { viewStore in
      ZStack {
        TextField(
          "🔍  지역, 지하철로 검색",
          text: viewStore.binding(\.$searchText)
        )
        .frame(height: 35)
        .padding(.leading, 5)
        .padding(.trailing, 25)
        .overlay {
          RoundedRectangle(cornerRadius: 5)
            .stroke(.gray, lineWidth: 1)
        }
        .onSubmit {
          viewStore.send(.searchTextSubmitted)
        }

        HStack {
          Spacer()
          Button {
            viewStore.send(.searchTextFieldClearButtonClicked)
          } label: {
            Image(systemName: "xmark.circle.fill")
              .foregroundColor(.gray)
              .padding(.trailing, 5)
          }
        }
      }
      .padding(.horizontal, 16)
    }
  }

  var orderFilterView: some View {
    WithViewStore(store) { viewStore in
      ScrollView(.horizontal) {
        HStack(spacing: 8) {
          ForEach(viewStore.filterOrders, id: \.self) { order in
            Button {
              viewStore.send(.filterOrderMenuClicked(order))
            } label: {
              Text(order.title)
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

// TODO: 추후 UI정해지면 별도 파일 생성 필요.
struct CafePreview: View {
  @State var heartButtonTapped: Bool = false

  var body: some View {
    RoundedRectangle(cornerRadius: 15)
      .foregroundColor(.white)
      .shadow(color: .gray, radius: 2, x: 0, y: 2)
      .overlay {
        VStack(alignment: .leading, spacing: 15) {
          Spacer()
          HStack {
            Text("학림다방")
              .font(.headline)
            Spacer()
            Button {
              heartButtonTapped.toggle()
            } label: {
              Image(systemName: heartButtonTapped ? "heart.fill" : "heart")
                .foregroundColor(heartButtonTapped ? .red: .gray)
            }
          }
          .padding(.horizontal)

          Text("영업중")
            .font(.caption)
            .padding(EdgeInsets(top: 3, leading: 7, bottom: 3, trailing: 7))
            .overlay {
              RoundedRectangle(cornerRadius: 4)
                .stroke(Color.red, lineWidth: 1)
            }
            .padding(.leading)
            .foregroundColor(.red)

          HStack {
            HStack(spacing: 3) {
              Image(systemName: "paperplane.fill")
              Text("32382m")
                .font(.caption)
            }
            .foregroundColor(.gray)
            HStack(spacing: 3) {
              Image(systemName: "hand.thumbsup.fill")
                .foregroundColor(.red)
              Text("88%")
                .font(.caption)

            }
            HStack(spacing: 3) {
              Image(systemName: "heart")
                .foregroundColor(.red)
              Text("6")
                .font(.caption)
            }
          }
          .padding(.horizontal)
          Spacer()
        }
      }
  }
}
