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
    WithViewStore(store) { viewStore in
      VStack(spacing: 10) {
        textFieldWithBindingState
        textFieldWithoutBindingState
      }
      .padding(20)
      .customNavigationBar(
        centerView: {
          Text(viewStore.title)
        },
        leftView: {
          Button {
            viewStore.send(.popView)
          } label: {
            Image(systemName: "chevron.left")
          }
        }
      )
      .onAppear {
        viewStore.send(.onAppear)
      }
    }
  }
}

extension DevTestView {
  private var textFieldWithBindingState: some View {
    WithViewStore(store) { viewStore in
      TextField(
        "textField with BindingState",
        text: viewStore.binding(\.$textFieldStringWithBindingState)
      )
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
    WithViewStore(store) { viewStore in
      EmptyView()
      TextField(
        "textField without BindingState",
        text: viewStore.binding(
          get: \.textFieldStringWithoutBindingState,
          send: DevTest.Action.textFieldStringDidChange
        )
      )
      .frame(height: 35)
      .padding(.horizontal, 5)
      .padding(.trailing, 25)
      .overlay {
        RoundedRectangle(cornerRadius: 5)
          .stroke(.gray, lineWidth: 1)
      }
    }
  }
}

struct DevTestView_Previews: PreviewProvider {
  static var previews: some View {
    DevTestView(
      store: .init(
        initialState: .initialState,
        reducer: DevTest()
      )
    )
  }
}
