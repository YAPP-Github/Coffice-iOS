//
//  CafeSearchView.swift
//  coffice
//
//  Created by sehooon on 2023/07/03.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct CafeSearchView: View {
  enum Field: Hashable {
    case keyword
  }

  @FocusState private var focusField: Field?
  let store: StoreOf<CafeSearchViewCore>

  var body: some View {
    WithViewStore(store) { viewStore in
      VStack(spacing: 0) {
        cafeSearchHeaderView
        Divider()
          .frame(minHeight: 2)
          .background(Color(asset: CofficeAsset.Colors.grayScale2))
        cafeSearchBodyView
          .transition(.move(edge: .bottom))
      }
      .onAppear {
        focusField = .keyword
        viewStore.send(.onApear)
      }
    }
  }
}

extension CafeSearchView {
  var cafeSearchHeaderView: some View {
    WithViewStore(store) { viewStore in
      HStack(spacing: 0) {
        HStack(spacing: 0) {
          CofficeAsset.Asset.searchLine24px.swiftUIImage
            .padding(.trailing, 12)
          TextField( "지하철, 카페 이름으로 검색", text: viewStore.binding(\.$searchText))
            .onSubmit { viewStore.send(.submitText) }
            .textFieldStyle(.plain)
            .focused($focusField, equals: .keyword)
            .keyboardType(.default)
            .lineLimit(1)
          Button {
          } label: {
            CofficeAsset.Asset.closeCircleFill18px.swiftUIImage
              .renderingMode(.template)
              .foregroundColor(Color(asset: CofficeAsset.Colors.grayScale6))
          }
          Button {
            viewStore.send(.dismiss)
          } label: {
            CofficeAsset.Asset.close24px.swiftUIImage
          }
        }
        .padding(EdgeInsets(top: 0, leading: 20, bottom: 16, trailing: 16))
      }
      .frame(height: 64)
    }
  }

  var cafeSearchBodyView: some View {
    WithViewStore(store) { viewStore in
      switch viewStore.currentBodyType {
      case .recentSearchListView:
        recentSearchListView
      case .searchResultEmptyView:
        searchResultEmptyView
      case .searchResultListView:
        searchResultListView
      }
    }
  }

  var searchResultListView: some View {
    WithViewStore(store) { viewStore in
      VStack {
        ScrollView {
          ForEach(viewStore.cafeList, id: \.self) {_ in
            Text("")
          }
        }
      }
    }
  }

  var searchResultEmptyView: some View {
    VStack {
      Spacer()
      CofficeAsset.Asset.errorWarningFill40px.swiftUIImage
        .padding(.bottom, 12)
      VStack(spacing: 12) {
        Text("검색결과가 없어요!")
        Text("다른 검색어로 다시 검색해주세요.")
      }
      Spacer()
    }
  }

  var recentSearchListView: some View {
    WithViewStore(store) { viewStore in
      VStack(alignment: .leading, spacing: 0) {
        Text("최근검색어")
          .applyCofficeFont(font: .header3)
          .foregroundColor(Color(asset: CofficeAsset.Colors.grayScale9))
          .multilineTextAlignment(.leading)
          .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 16))
          .frame(maxWidth: .infinity, alignment: .leading)
          .frame(height: 60)
        ScrollView(.vertical, showsIndicators: false) {
          VStack(spacing: 0) {
            ForEach(viewStore.state.recentSearchKeyWordList.indices, id: \.self) { index in
              listCell(viewStore.state.recentSearchKeyWordList[index].text, index)
            }
          }
        }
      }
    }
  }

  func listCell(_ recentWord: String, _ id: Int) -> some View {
    WithViewStore(store) { viewStore in
      HStack(spacing: 0) {
        HStack(spacing: 16) {
          CofficeAsset.Asset.searchLine24px.swiftUIImage
            .resizable()
            .frame(width: 18, height: 18)
            .scaledToFit()
          Text(recentWord)
            .applyCofficeFont(font: .subtitleSemiBold)
            .foregroundColor(Color(asset: CofficeAsset.Colors.grayScale9))
        }
        .padding(EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 16))
        Spacer()
        Button {
          viewStore.send(.deleteRecentSearchWord(id))
        } label: {
          CofficeAsset.Asset.closeCircleFill18px.swiftUIImage
            .renderingMode(.template)
            .foregroundColor(Color(asset: CofficeAsset.Colors.grayScale6))
        }
        .padding(EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 16))
      }
      .frame(height: 52)
    }
  }
}

struct CafeSearchView_Previews: PreviewProvider {
  static var previews: some View {
    CafeSearchView(
      store: Store(
        initialState: CafeSearchViewCore.State(), reducer: {
          CafeSearchViewCore()
        }
      )
    )
  }
}
