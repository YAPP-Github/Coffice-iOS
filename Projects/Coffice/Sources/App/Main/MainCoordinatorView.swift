//
//  MainCoordinatorView.swift
//  Cafe
//
//  Created by MinKyeongTae on 2023/05/26.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture
import SwiftUI
import TCACoordinators

struct MainCoordinatorView: View {
  let store: StoreOf<MainCoordinator>

  var body: some View {
    WithViewStore(store) { viewStore in
      ZStack {
        NavigationView {
          mainView
        }
        tabBarView

        if viewStore.isBubbleMessageViewPresented,
           let viewState = viewStore.bubbleMessageViewState {
          bubbleMessageView(viewState: viewState)
        }
      }
      .onAppear {
        viewStore.send(.onAppear)
      }
    }
  }

  var mainView: some View {
    WithViewStore(store, observe: \.selectedTab) { viewStore in
      Group {
        switch viewStore.state {
        case .search:
          SearchCoordinatorView(
            store: store.scope(
              state: \.searchState,
              action: MainCoordinator.Action.search
            )
          )
        case .savedList:
          SavedListCoordinatorView(
            store: store.scope(
              state: \.savedListState,
              action: MainCoordinator.Action.savedList
            )
          )
        case .myPage:
          MyPageCoordinatorView(
            store: store.scope(
              state: \.myPageState,
              action: MainCoordinator.Action.myPage
            )
          )
        }
      }
    }
  }

  var tabBarView: some View {
    WithViewStore(store) { viewStore in
      VStack {
        Spacer()
        TabBarView(
          store: store.scope(
            state: \.tabBarState,
            action: MainCoordinator.Action.tabBar
          )
        )
      }
    }
  }

  func bubbleMessageView(
    viewState: MainCoordinator.State.BubbleMessageViewState
  ) -> some View {
    WithViewStore(store) { viewStore in
      ZStack(alignment: .center) {
        Color.black.opacity(0.4).ignoresSafeArea()

        VStack(alignment: .leading, spacing: 0) {
          Text(viewState.title)
            .foregroundColor(Color(asset: CofficeAsset.Colors.grayScale8))
            .applyCofficeFont(font: .button)
            .frame(height: 20, alignment: .leading)
          Text(viewState.subTitle)
            .foregroundColor(Color(asset: CofficeAsset.Colors.grayScale6))
            .applyCofficeFont(font: .body2)
            .frame(height: 20, alignment: .leading)

          VStack(spacing: 10) {
            ForEach(viewState.subInfoViewStates) { subInfoViewState in
              HStack(spacing: 0) {
                Image(asset: subInfoViewState.iconImage)
                  .resizable()
                  .frame(width: 20, height: 20)
                Text(subInfoViewState.title)
                  .foregroundColor(Color(asset: CofficeAsset.Colors.grayScale8))
                  .applyCofficeFont(font: .body2Medium)
                  .padding(.leading, 8)
                Text(subInfoViewState.description)
                  .foregroundColor(Color(asset: CofficeAsset.Colors.grayScale7))
                  .applyCofficeFont(font: .body2Medium)
                  .padding(.leading, 4)

                Spacer()
              }
              .frame(height: 20)
            }
          }
          .padding(.top, 24)
        }
        .padding(20)
        .frame(width: 204, alignment: .center)
        .background(Color(asset: CofficeAsset.Colors.grayScale1))
        .cornerRadius(8)
      }
      .onTapGesture {
        viewStore.send(.dismissBubbleMessageView)
      }
    }
  }
}

struct MainCoordinatorView_Previews: PreviewProvider {
  static var previews: some View {
    MainCoordinatorView(
      store: .init(
        initialState: .initialState,
        reducer: MainCoordinator()
      )
    )
  }
}
