//
//  CafeMapView.swift
//  Cafe
//
//  Created by sehooon on 2023/05/29.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import SwiftUI
import NMapsMap
import ComposableArchitecture

struct CafeMapView: View {
  let store: StoreOf<CafeMapCore>

  var body: some View {
    WithViewStore(store) { viewStore in
      ZStack {
        NaverMapView(viewStore: viewStore)
          .ignoresSafeArea()
        VStack {
          header
            .background(.white)
          Spacer()
          HStack {
            Button {
              viewStore.send(.currentLocationButtonTapped)
            } label: {
              Circle()
                .foregroundColor(.white)
                .shadow(color: .gray, radius: 2, x: 0, y: 2)
                .overlay {
                  Image(systemName: "scope")
                }
                .frame(width: 50, height: 50)
            }
            .buttonStyle(.plain)
            Spacer()
          }
          .padding()
          CafePreview()
            .frame(width: 350, height: 150)
        }
      }
      .onAppear {
        viewStore.send(.requestAuthorization)
      }
    }
  }
}

extension CafeMapView {
  var header: some View {
    HStack(spacing: 8) {
      ForEach(["영업중", "혼잡도낮은순", "가까운순", "추천순"], id: \.self) { status in
        Button {
        } label: {
          Text("\(status)")
            .font(.subheadline)
            .foregroundColor(.black)
            .lineLimit(1)
            .padding(EdgeInsets(top: 7, leading: 12, bottom: 7, trailing: 12))
            .overlay {
              RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray, lineWidth: 1)
            }
        }
      }
      Spacer()
    }
    .padding()
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
