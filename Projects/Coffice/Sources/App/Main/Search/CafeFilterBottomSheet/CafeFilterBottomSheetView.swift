//
//  CafeFilterBottomSheetView.swift
//  coffice
//
//  Created by sehooon on 2023/06/27.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct CafeFilterBottomSheetView: View {
  private let store: StoreOf<CafeFilterBottomSheet>
  @State var isSheetPresented = false
  @State private var height = CGFloat.zero
  let isDimmed: Bool = false
  let isDragAble: Bool = false
  let delayTime = 0.000001

  init(store: StoreOf<CafeFilterBottomSheet>) {
    self.store = store
  }

  var body: some View {
    WithViewStore(store) { viewStore in
      GeometryReader { proxy in
        ZStack {
          CofficeAsset.Colors.grayScale9.swiftUIColor
            .opacity(0.4)
            .ignoresSafeArea()
            .onTapGesture {
              viewStore.send(.dismiss)
            }
            .onAppear {
              DispatchQueue.main.asyncAfter(deadline: .now() + delayTime) {
                withAnimation { isSheetPresented = true }
              }
            }

          if isSheetPresented {
            RoundedRectangle(cornerRadius: 15)
              .transition(.move(edge: .bottom))
              .foregroundColor(CofficeAsset.Colors.grayScale1.swiftUIColor)
              .shadow(color: .gray, radius: 5)
              .overlay {
                VStack(spacing: 0) {
                  filterOptionButtonContainerView
                  footerView
                  Spacer()
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
              }
              .onAppear { height = proxy.size.height }
              .offset(y: height - viewStore.bottomSheetHeight)
          }
        }
        .frame(width: proxy.size.width, height: proxy.size.height)
      }
    }
  }
}

extension CafeFilterBottomSheetView {
  var headerView: some View {
    WithViewStore(store) { viewStore in
      HStack(spacing: 0) {
        Text(viewStore.filterType.title)
          .foregroundColor(CofficeAsset.Colors.grayScale9.swiftUIColor)
          .applyCofficeFont(font: .header1)
          .frame(height: 32)
          .padding(.top, 28)
          .padding(.bottom, 20)
        Button {
          viewStore.send(.infoGuideButtonTapped)
        } label: {
          CofficeAsset.Asset.informationLine18px.swiftUIImage
            .renderingMode(.template)
            .foregroundColor(CofficeAsset.Colors.grayScale6.swiftUIColor)
            .padding(.top, 35)
            .padding(.leading, 8)
            .padding(.bottom, 27)
        }

        Spacer()

        Button {
          viewStore.send(.dismiss)
        } label: {
          CofficeAsset.Asset.close40px.swiftUIImage
            .padding(.top, 24)
            .padding(.bottom, 16)
        }
      }
      .frame(height: 80)
      .padding(.horizontal, 20)
    }
  }

  var filterOptionButtonContainerView: some View {
    WithViewStore(store) { viewStore in
      VStack(spacing: 0) {
        headerView
        mainScrollView
      }
    }
  }

  var mainScrollView: some View {
    WithViewStore(store) { viewStore in
      ScrollView(.vertical) {
        VStack(alignment: .leading, spacing: 0) {
          ForEach(viewStore.mainViewState.optionButtonCellViewStates.indices, id: \.self) { index in
            let cellViewState = viewStore.mainViewState.optionButtonCellViewStates[safe: index]
            let viewStates = cellViewState?.viewStates ?? []
            if viewStore.shouldShowSubSectionView {
              Text(cellViewState?.sectionTitle ?? "-")
                .applyCofficeFont(font: .header3)
                .foregroundColor(CofficeAsset.Colors.grayScale8.swiftUIColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 20)
                .padding(.bottom, 16)
            }

            if viewStates.isNotEmpty {
              HStack(spacing: 8) {
                ForEach(viewStates) { viewState in
                  let option = viewState.option
                  Button {
                    viewStore.send(.optionButtonTapped(optionType: option))
                  } label: {
                    Text(viewState.buttonTitle)
                      .applyCofficeFont(font: .body1Medium)
                      .foregroundColor(viewState.foregroundColor.swiftUIColor)
                      .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                      .cornerRadius(16)
                      .background(viewState.backgroundColor.swiftUIColor.clipShape(Capsule()))
                      .overlay {
                        RoundedRectangle(cornerRadius: 18)
                          .stroke(viewState.borderColor.swiftUIColor, lineWidth: 1)
                      }
                      .frame(height: 36)
                  }
                }
              }
              .frame(maxWidth: .infinity, alignment: .leading)
              .frame(height: 36)
              .padding(.bottom, 36)
            } else {
              EmptyView()
            }
          }
        }
        .padding(.leading, 20)
      }
      .frame(height: viewStore.scrollViewHeight)
      .padding(.top, 20)
    }
  }

  var footerView: some View {
    WithViewStore(store) { viewStore in
      HStack(alignment: .center, spacing: 12) {
        Button {
          viewStore.send(.resetCafeFilterButtonTapped)
        } label: {
          Text("초기화")
            .foregroundColor(CofficeAsset.Colors.grayScale9.swiftUIColor)
            .applyCofficeFont(font: .button)
            .frame(maxWidth: .infinity, alignment: .center)
            .frame(height: 44)
            .overlay {
              RoundedRectangle(cornerRadius: 4)
                .stroke(CofficeAsset.Colors.grayScale4.swiftUIColor, lineWidth: 1)
            }
        }

        Button {
          viewStore.send(.saveCafeFilterButtonTapped)
        } label: {
          Text("저장하기")
            .foregroundColor(CofficeAsset.Colors.grayScale1.swiftUIColor)
            .applyCofficeFont(font: .button)
            .frame(maxWidth: .infinity, alignment: .center)
            .frame(height: 44)
            .background(
              CofficeAsset.Colors.grayScale9.swiftUIColor
                .frame(height: 44)
                .cornerRadius(4, corners: .allCorners)
            )
        }
      }
      .frame(height: 84)
      .padding(.horizontal, 20)
    }
  }
}

struct CafeFilterBottomSheetView_Previews: PreviewProvider {
  static var previews: some View {
    CafeFilterBottomSheetView(
      store: .init(
        initialState: .mock,
        reducer: CafeFilterBottomSheet()
      )
    )
  }
}
