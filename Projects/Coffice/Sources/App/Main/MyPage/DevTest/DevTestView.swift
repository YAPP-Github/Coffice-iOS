//
//  DevTestView.swift
//  Cafe
//
//  Created by Min Min on 2023/06/13.
//  Copyright (c) 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct DevTestView: View {
  let store: StoreOf<DevTest>

  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 10) {
        textFieldWithBindingState
        textFieldWithoutBindingState
        cafeFilterBottomSheetTestView
      }
      .padding(20)
      .customNavigationBar(
        centerView: {
          Text(viewStore.title)
        },
        leftView: {
          EmptyView()
        },
        rightView: {
          Button {
            viewStore.send(.dismissButtonTapped)
          } label: {
            CofficeAsset.Asset.close40px.swiftUIImage
          }
        }
      )
      .popup(
        item: viewStore.binding(
          get: \.cafeFilterBottomSheetState,
          send: { .set(\.$cafeFilterBottomSheetState, $0) }
        ),
        itemView: { viewState in
          CafeFilterBottomSheetView(
            store: store.scope(
              state: { _ in viewState },
              action: DevTest.Action.cafeFilterBottomSheetAction
            )
          )
        },
        customize: BottomSheetContent.customize
      )
      .onAppear {
        viewStore.send(.onAppear)
      }
    }
  }
}

extension DevTestView {
  private var textFieldWithBindingState: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      TextField(
        "textField with BindingState",
        text: viewStore.binding(
          get: \.textFieldStringWithBindingState,
          send: { .set(\.$textFieldStringWithBindingState, $0) }
        )
      )
      .textFieldStyle(.plain)
      .frame(height: 35)
      .padding(.horizontal, 5)
      .padding(.trailing, 25)
      .overlay {
        RoundedRectangle(cornerRadius: 5)
          .stroke(.gray, lineWidth: 1)
      }
    }
  }

  private var textFieldWithoutBindingState: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      EmptyView()
      TextField(
        "textField without BindingState",
        text: viewStore.binding(
          get: \.textFieldStringWithoutBindingState,
          send: DevTest.Action.textFieldStringDidChange
        )
      )
      .textFieldStyle(.plain)
      .frame(height: 35)
      .padding(.horizontal, 5)
      .padding(.trailing, 25)
      .overlay {
        RoundedRectangle(cornerRadius: 5)
          .stroke(.gray, lineWidth: 1)
      }
    }
  }

  private var cafeFilterBottomSheetTestView: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      Button {
        viewStore.send(.presentCafeFilterBottomSheetView)
      } label: {
        Text("Present CafeFilterBottomSheet")
          .foregroundColor(CofficeAsset.Colors.grayScale9.swiftUIColor)
          .applyCofficeFont(font: .button)
          .frame(height: 35)
          .frame(maxWidth: .infinity, alignment: .center)
          .overlay {
            RoundedRectangle(cornerRadius: 5)
              .stroke(CofficeAsset.Colors.grayScale7.swiftUIColor, lineWidth: 1)
          }
      }
    }
  }
}

struct DevTestView_Previews: PreviewProvider {
  static var previews: some View {
    DevTestView(
      store: .init(
        initialState: .initialState,
        reducer: {
          DevTest()
        }
      )
    )
  }
}
