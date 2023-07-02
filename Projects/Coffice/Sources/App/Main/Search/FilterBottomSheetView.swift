//
//  CustomBottomSheet.swift
//  coffice
//
//  Created by sehooon on 2023/06/27.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct FilterBottomSheetView: View {
  let isDimmed: Bool = false
  let isDragAble: Bool = false
  private let store: StoreOf<FilterSheetCore>

  @State var isApearSheet = false
  @State private var height = CGFloat.zero

  init(store: StoreOf<FilterSheetCore>) {
    self.store = store
  }

  var body: some View {
    WithViewStore(store) { viewStore in
      GeometryReader { proxy in
        ZStack {
          Color.black.opacity(0.5).ignoresSafeArea().onTapGesture {
            viewStore.send(.dismiss)
          }
          .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.000001) {
              withAnimation { isApearSheet = true }
              }
            }
          if isApearSheet {
            RoundedRectangle(cornerRadius: 15)
              .transition(.move(edge: .bottom))
              .foregroundColor(.white)
              .shadow(color: .gray, radius: 5)
              .overlay {
                VStack(spacing: 0) {
                  switch viewStore.filterType {
                  case .cafeDetailFilter:
                    cafeDetailFilterView
                  case .outlet:
                    cafeOutletFilterView
                  case .spaceSize:
                    cafeSizeFilterView
                  case .runningTime:
                    cafeRunningTimeFilterView
                  case .personnel:
                    cafePersonnelFilterView
                  default:
                    EmptyView()
                  }
                  Spacer()
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
              }
              .onAppear { height = proxy.size.height }
              // TODO: Filter별 높이 조정
              .offset(y: height - 200)
          }
        }
        .frame(width: proxy.size.width, height: proxy.size.height)
      }
    }
  }
}

extension FilterBottomSheetView {
  var headerView: some View {
    WithViewStore(store) { viewStore in
      HStack(spacing: 0) {
        Text(viewStore.filterType.titleName)
          .font(.headline)
        Spacer()
        Button {
          viewStore.send(.dismiss)
        } label: {
          Image(asset: CofficeAsset.Asset.close40px)
        }
      }
      .frame(height: 85)
    }
  }

  var resetAndSaveButtonView: some View {
    WithViewStore(store) { viewStore in
      HStack {
        Button {

        } label: {
          Text("초기화")
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
        Spacer()
          .frame(width: 150)
        Button {

        } label: {
          Text("저장")
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
        Spacer()
      }
    }
  }

  var cafeOutletFilterView: some View {
    WithViewStore(store) { viewStore in
      headerView
      HStack {
        ForEach(viewStore.outletButtonViewState.indices, id: \.self) { idx in
          Button {
            viewStore.send(.buttonTapped(idx, .outlet))
          } label: {
            Text(viewStore.outletButtonViewState[idx].buttonTitle)
          }
          .background(Color(asset: viewStore.outletButtonViewState[idx].backgroundColor))
        }
      }
    }
  }
  // TODO: FilterView 구성
  var cafeSizeFilterView: some View { headerView }
  var cafeRunningTimeFilterView: some View { headerView }
  var cafePersonnelFilterView: some View { headerView }
  var cafeDetailFilterView: some View { headerView }
}
