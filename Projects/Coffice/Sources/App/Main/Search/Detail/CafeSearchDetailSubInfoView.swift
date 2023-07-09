//
//  CafeSearchDetailSubInfoView.swift
//  coffice
//
//  Created by Min Min on 2023/06/26.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct CafeSearchDetailSubInfoView: View {
  private let store: StoreOf<CafeSearchDetail>

  init(store: StoreOf<CafeSearchDetail>) {
    self.store = store
  }

  var body: some View {
    WithViewStore(store) { _ in
      VStack(spacing: 0) {
        VStack(spacing: 0) {
          cafeSubPrimaryInfoView
          cafeSecondaryInfoView
        }
        .padding(.horizontal, 20)

        Color(UIColor.lightGray)
          .frame(height: 4)
          .padding(.top, 20)
      }
    }
  }
}

extension CafeSearchDetailSubInfoView {
  private var cafeSubPrimaryInfoView: some View {
    WithViewStore(store, observe: \.subPrimaryInfoViewStates) { viewStore in
      VStack(alignment: .leading, spacing: 0) {
        Text("카페정보")
          .foregroundColor(.black)
          .font(.system(size: 16, weight: .bold))
          .frame(alignment: .leading)
          .frame(height: 20)
          .padding(.top, 16)

        HStack {
          ForEach(viewStore.state) { viewState in
            VStack(alignment: .center, spacing: 12) {
              Image(systemName: viewState.iconName)
                .resizable()
                .frame(width: 30, height: 30)
                .overlay(alignment: .topTrailing) {
                  Button {
                    viewStore.send(.infoGuideButtonTapped(viewState.guideType))
                  } label: {
                    Image(asset: CofficeAsset.Asset.informationLine18px)
                      .resizable()
                      .frame(width: 18, height: 18)
                  }
                  .offset(x: 5, y: -5)
                }
              HStack(spacing: 8) {
                Text(viewState.title)
                  .foregroundColor(.black)
                  .font(.system(size: 14))
                  .frame(height: 20)
                Text(viewState.description)
                  .foregroundColor(.gray)
                  .font(.system(size: 14))
                  .frame(height: 20)
              }
              .fixedSize(horizontal: true, vertical: true)
            }

            if viewState.type != .groupSeat {
              Spacer()
            }
          }
          .padding(.top, 16)
        }

        Divider()
          .padding(.top, 20)
      }
    }
  }

  private var cafeSecondaryInfoView: some View {
    WithViewStore(store, observe: \.subSecondaryInfoViewStates) { viewStore in
      VStack(alignment: .leading, spacing: 0) {
        HStack {
          VStack(spacing: 0) {
            ForEach(viewStore.state) { viewState in
              Text(viewState.title)
                .foregroundColor(.black)
                .font(.system(size: 14, weight: .semibold))
                .frame(height: 20)
                .frame(maxWidth: 50, alignment: .leading)
                .padding(.bottom, 16)
            }
          }

          VStack(alignment: .leading, spacing: 0) {
            ForEach(viewStore.state) { viewState in
              HStack {
                Text(viewState.description)
                  .foregroundColor(.gray)
                  .font(.system(size: 14))
                  .frame(alignment: .leading)

                if viewState.type == .congestion {
                  Text(viewState.congestionDescription)
                    .foregroundColor(viewState.congestionLevel == .high ? .red : .black)
                    .font(.system(size: 14))

                  Spacer()

                  Text("6월 22일 16:00 기준")
                    .foregroundColor(.gray)
                    .font(.system(size: 12))
                    .frame(alignment: .trailing)
                }
              }
              .frame(height: 20)
              .padding(.bottom, 16)
            }
          }
        }
      }
      .padding(.top, 20)
    }
  }
}

struct CafeSearchDetailSubInfoView_Previews: PreviewProvider {
  static var previews: some View {
    CafeSearchDetailSubInfoView(
      store: .init(
        initialState: .init(cafeId: 1),
        reducer: CafeSearchDetail()
      )
    )
  }
}
