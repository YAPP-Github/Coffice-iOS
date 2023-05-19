//
//  AppView.swift
//  YappProject
//
//  Created by Min Min on 2023/05/06.
//

import SwiftUI
import ComposableArchitecture

struct AppView: View {
  let store: StoreOf<YappProject>

  var body: some View {
    mainView
  }

  var mainView: some View {
    WithViewStore(store) { viewStore in
      VStack {
        // TODO: Navigation 화면 전환 테스트용 코드, 추후 제거 필요
        Button {
          viewStore.send(.secondActive(true))
        } label: {
          Text("😀 Push Navigation View")
            .foregroundColor(.blue)
            .frame(height: 50.0)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16.0)
        }

        // TODO: Modal 화면 전환 테스트용 코드, 추후 제거 필요
        Button {
          debugPrint("Present Modal View")
          viewStore.send(.modalPresented(true))
        } label: {
          Text("😀 Present Modal View")
            .foregroundColor(.blue)
            .frame(height: 50.0)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16.0)
        }

        Button {
          viewStore.send(.getCoffees)
        } label: {
          Text("💻 Get Coffees")
            .foregroundColor(.blue)
            .frame(height: 50.0)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16.0)
        }

        if let coffeeDescription = viewStore.coffeeDescription {
          ScrollView(.vertical) {
            VStack(spacing: 0) {
              Text(coffeeDescription)
            }
            .padding(.horizontal, 16.0)
          }
        }

        Spacer()
      }
      .navigationTitle(viewStore.title)
      .navigationBarTitleDisplayMode(.inline)
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    AppView(
      store: .init(
        initialState: .init(),
        reducer: YappProject()
      )
    )
  }
}
