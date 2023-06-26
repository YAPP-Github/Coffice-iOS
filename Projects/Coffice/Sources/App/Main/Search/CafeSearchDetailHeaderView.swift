//
//  CafeSearchDetailHeaderView.swift
//  coffice
//
//  Created by Min Min on 2023/06/26.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct CafeSearchDetailHeaderView: View {
  private let store: StoreOf<CafeSearchDetail>

  init(store: StoreOf<CafeSearchDetail>) {
    self.store = store
  }

  var body: some View {
    WithViewStore(store) { _ in
      VStack(spacing: 0) {
        Image("cafeImage")
          .resizable()
          .frame(height: 200 + (UIApplication.keyWindow?.safeAreaInsets.top ?? 0))
          .scaledToFit()

        VStack(spacing: 0) {
          HStack {
            VStack(spacing: 0) {
              Text("카페")
                .foregroundColor(.black)
                .font(.system(size: 14, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 20)
              Text("훅스턴")
                .foregroundColor(.black)
                .font(.system(size: 26, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 36)
                .padding(.top, 8)
              Text("서울 서대문구 연희로 91 2층")
                .foregroundColor(.gray)
                .font(.system(size: 14))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 4)
            }

            VStack {
              Image(systemName: "bookmark")
                .resizable()
                .frame(width: 20, height: 24)
                .padding(.top, 10)
              Spacer()
            }
          }

          HStack(spacing: 8) {
            Text("영업중")
              .foregroundColor(.brown)
              .font(.system(size: 14, weight: .bold))
              .frame(alignment: .leading)
            Text("목 09:00 ~ 21:00")
              .foregroundColor(.gray)
              .font(.system(size: 14))
            Spacer()
          }
          .padding(.top, 16)

          Divider()
            .padding(.top, 20)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
      }
    }
  }
}
