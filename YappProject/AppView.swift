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
    WithViewStore(store) { viewStore in
      NavigationView {
        VStack {
          Button {
            viewStore.send(.secondActive(true))
          } label: {
            Text("😀 Push Navigation View")
              .foregroundColor(.blue)
              .frame(height: 50.0)
              .frame(maxWidth: .infinity)
              .padding(.horizontal, 16.0)
          }

          Button {
            debugPrint("Present Modal View")
            viewStore.send(.thirdPresented(true))
          } label: {
            Text("😀 Present Modal View")
              .foregroundColor(.blue)
              .frame(height: 50.0)
              .frame(maxWidth: .infinity)
              .padding(.horizontal, 16.0)
          }
          
          Spacer()
        }
        .navigationTitle(viewStore.title)
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(
          isPresented: viewStore.binding(
            get: \.isThirdPresented,
            send: YappProject.Action.thirdPresented
          ),
          content: {
            IfLetStore(
              store.scope(
                state: \.thirdState,
                action: YappProject.Action.third
              ),
              then: ThirdView.init
            )
          }
        )
        .background(emptyNavigationLink)
      }
    }
  }
  
  var emptyNavigationLink: some View {
    WithViewStore(store) { viewStore in
      NavigationLink(
        destination: IfLetStore(
          store.scope(
            state: \.secondState,
            action: YappProject.Action.second
          ),
          then: SecondView.init
        ),
        isActive: viewStore.binding(
          get: \.isSecondActive,
          send: YappProject.Action.secondActive),
        label: {
          EmptyView()
        }
      )
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
