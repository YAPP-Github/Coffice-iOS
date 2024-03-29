//
//  MyPageView.swift
//  Cafe
//
//  Created by MinKyeongTae on 2023/05/26.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture
import PopupView
import SwiftUI

struct MyPageView: View {
  private let store: StoreOf<MyPage>

  init(store: StoreOf<MyPage>) {
    self.store = store
  }

  var body: some View {
    WithViewStore(
      store,
      observe: { $0 },
      content: { viewStore in
        mainView
          .navigationBarHidden(true)
          .onAppear {
            viewStore.send(.onAppear)
          }
          .popup(
            isPresented: viewStore.$shouldShowBottomSheet,
            view: {
              BottomSheetView(
                store: store.scope(
                  state: \.bottomSheetState,
                  action: MyPage.Action.bottomSheet
                ),
                bottomSheetContent: viewStore.bottomSheetType.content
              )
            },
            customize: { BottomSheetContent.customize($0) }
          )
          .sheet(
            item: viewStore.binding(
              get: \.contactEmailViewState,
              send: { .set(\.$contactEmailViewState, $0) }
            ),
            content: { viewState in
              ContactEmailView(
                contactEmailViewState: Binding(
                  get: { viewState },
                  set: { _ in }
                ),
                callback: { result in
                  switch result {
                  case .success:
                    debugPrint("ContactEmailView Action Finished")
                  case .failure(let error):
                    debugPrint(error.localizedDescription)
                  }
                  viewStore.send(.contactEmailView(isPresented: false))
                }
              )
            }
          )
          .sheet(
            item: viewStore.$devTestViewState,
            content: { viewState in
              DevTestView(store: store.scope(
                state: { _ in viewState },
                action: MyPage.Action.devTestAction
              ))
            }
          )
      }
    )
  }

  private var mainView: some View {
    WithViewStore(
      store,
      observe: { $0 },
      content: { viewStore in
        VStack(alignment: .leading, spacing: 0) {
          nickNameView
            .padding(.top, 110)

          if viewStore.user?.loginType == .anonymous {
            Color.clear
              .frame(width: 0, height: 0)
              .padding(.top, 56)
          } else {
            linkedAccountTypeView
          }
          
          ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
              ForEach(viewStore.menuItems) { menuItem in
                menuItemView(menuItem: menuItem)
              }
            }
            .padding(.vertical, 10)
          }

          Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, TabBarSizePreferenceKey.defaultValue.height)
      }
    )
  }

  private var nickNameView: some View {
    WithViewStore(
      store,
      observe: { $0 },
      content: { viewStore in
        HStack {
          Text(viewStore.user?.name ?? "닉네임")
            .applyCofficeFont(font: .header1)
            .foregroundColor(CofficeAsset.Colors.grayScale9.swiftUIColor)
          Spacer()
          Button {
            viewStore.send(
              .delegate(
                .editProfileButtonTapped(
                  nickname: viewStore.user?.name ?? "-",
                  loginType: viewStore.user?.loginType ?? .anonymous
                )
              )
            )
          } label: {
            HStack(spacing: 0) {
              Text(
                viewStore.user?.loginType == .anonymous
                ? "SNS 로그인"
                : "편집"
              )
              .applyCofficeFont(font: .button)
              CofficeAsset.Asset.arrowDropRightLine24px.swiftUIImage
                .renderingMode(.template)
                .frame(width: 24, height: 24)
            }
            .tint(CofficeAsset.Colors.grayScale1.swiftUIColor)
            .padding(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 2))
            .background(CofficeAsset.Colors.grayScale8.swiftUIColor)
            .cornerRadius(18)
          }
        }
      }
    )
  }

  private var linkedAccountTypeView: some View {
    WithViewStore(
      store,
      observe: { $0 },
      content: { viewStore in
        VStack(spacing: 0) {
          Divider()
          HStack(alignment: .center, spacing: 0) {
            Text("로그인")
              .applyCofficeFont(font: .header3)
              .foregroundColor(CofficeAsset.Colors.grayScale9.swiftUIColor)
              .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 8) {
              viewStore.user?.loginType?.image
                .resizable()
                .frame(width: 18, height: 18)
              Text(viewStore.user?.loginType?.displayName ?? "")
                .applyCofficeFont(font: .body2Medium)
                .foregroundColor(CofficeAsset.Colors.grayScale6.swiftUIColor)
                .padding(.trailing, 10)
            }
          }
          .padding(.vertical, 29)
          Divider()
        }
        .padding(.top, 29)
      }
    )
  }

  private func menuItemView(menuItem: MyPage.MenuItem) -> some View {
    WithViewStore(
      store,
      observe: { $0 },
      content: { viewStore in
        VStack(alignment: .leading, spacing: 0) {
          HStack {
            Button {
              viewStore.send(.menuButtonTapped(menuItem))
            } label: {
              Group {
                Text(menuItem.title)
                  .applyCofficeFont(font: .header3)
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .frame(height: 50)
                if menuItem.menuType == .versionInformation {
                  Text(viewStore.versionNumber)
                    .applyCofficeFont(font: .body1)
                    .tint(CofficeAsset.Colors.grayScale6.swiftUIColor)
                } else {
                  CofficeAsset.Asset.arrowDropRightLine24px.swiftUIImage
                    .renderingMode(.template)
                    .frame(width: 24, height: 24)
                }
              }
              .tint(menuItem.textColor)
            }
            .disabled(menuItem.menuType == .versionInformation)
          }
        }
      }
    )
  }

  private var divider: some View {
    Divider()
      .frame(minHeight: 2)
      .overlay(Color.black)
  }
}

struct MyPageView_Previews: PreviewProvider {
  static var previews: some View {
    MyPageView(
      store: .init(
        initialState: .init(),
        reducer: {
          MyPage()
        }
      )
    )
  }
}
