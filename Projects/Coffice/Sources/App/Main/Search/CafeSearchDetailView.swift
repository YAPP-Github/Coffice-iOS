//
//  CafeSearchDetailView.swift
//  coffice
//
//  Created by Min Min on 2023/06/24.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct CafeSearchDetailView: View {
  private let store: StoreOf<CafeSearchDetail>

  init(store: StoreOf<CafeSearchDetail>) {
    self.store = store
  }

  var body: some View {
    mainView
  }

  var mainView: some View {
    WithViewStore(store) { viewStore in
      VStack {
        ScrollView(.vertical) {
          VStack(spacing: 0) {
            headerView
            menuContainerView
          }
        }
      }
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
    }
  }

  private var headerView: some View {
    WithViewStore(store) { viewStore in
      VStack(spacing: 0) {
        Image("cafeImage")
          .resizable()
          .frame(height: 200)
          .scaledToFit()

        VStack(spacing: 5) {
          Text("카페 이름")
            .font(.title)
            .frame(maxWidth: .infinity, alignment: .leading)

          Text("서울 용산구 ~")
            .font(.subheadline)
            .frame(maxWidth: .infinity, alignment: .leading)

          HStack {
            Text("영업중")
              .font(.subheadline)
              .foregroundColor(.white)
              .background(.black)
              .cornerRadius(5)
            Text("목 09:00 ~ 21:00")
              .font(.subheadline)
            Spacer()
          }

          Divider()

          HStack(spacing: 0) {
            Button {
              // TODO: 저장하기 이벤트 구현 필요
            } label: {
              Text("저장하기")
                .frame(height: 50)
                .frame(maxWidth: .infinity)
            }

            Button {
              // TODO: 공유하기 이벤트 구현 필요
            } label: {
              Text("공유하기")
                .frame(height: 50)
                .frame(maxWidth: .infinity)
            }
          }
          .frame(maxWidth: .infinity)

          Divider()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
      }
    }
  }

  private var menuContainerView: some View {
    WithViewStore(store) { viewStore in
      VStack(spacing: 0) {
        HStack(spacing: 0) {
          ForEach(viewStore.subMenus, id: \.self) { subMenuType in
            Button {
              viewStore.send(.subMenuTapped(subMenuType))
            } label: {
              Text(subMenuType.title)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
            }
          }
        }

        Divider()

        switch viewStore.selectedSubMenuType {
        case .home:
          homeMenuView
        case .detailInfo:
          detailInfoMenuView
        case .review:
          reviewMenuView
        }
      }
    }
  }

  private var homeMenuView: some View {
    WithViewStore(store) { viewStore in
      VStack(spacing: 0) {
        Button {
          viewStore.send(.toggleToPresentTextForTest)
        } label: {
          HStack {
            Text("토 09:00 - 21:00")
              .foregroundColor(.black)
              .frame(maxWidth: .infinity)

            if viewStore.needToPresentTextForTest {
              Image(systemName: "chevron.up")
                .tint(Color.black)
            } else {
              Image(systemName: "chevron.down")
                .tint(Color.black)
            }
          }
          .padding(.horizontal, 16)
        }

        Text(viewStore.textForTest)
      }
      .padding(.top, 10)
    }
  }

  private var detailInfoMenuView: some View {
    VStack(spacing: 0) {
      EmptyView()
    }
  }

  private var reviewMenuView: some View {
    VStack(spacing: 0) {
      EmptyView()
    }
  }
}

struct CafeSearchDetailView_Previews: PreviewProvider {
  static var previews: some View {
    CafeSearchDetailView(
      store: .init(
        initialState: .init(),
        reducer: CafeSearchDetail()
      )
    )
  }
}
