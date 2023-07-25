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
  let store: StoreOf<CafeSearchCore>

  var body: some View {
    WithViewStore(store) { viewStore in
      VStack(spacing: 0) {
        cafeSearchHeaderView
          .background(alignment: .bottom) {
            CofficeAsset.Colors.grayScale2.swiftUIColor
              .frame(height: 2)
          }
        cafeSearchBodyView
      }
      .onAppear {
        focusField = .keyword
        viewStore.send(.onAppear)
      }
    }
  }
}

extension CafeSearchView {
  var cafeSearchBodyView: some View {
    WithViewStore(store, observe: \.bodyType) { viewStore in
      switch viewStore.state {
      case .recentSearchWordsView:
        recentSearchWordsView

      case .searchResultEmptyView:
        searchResultEmptyView

      case .searchResultListView:
        searchResultListView
      }
    }
  }

  var cafeSearchHeaderView: some View {
    WithViewStore(store) { viewStore in
      HStack(alignment: .top, spacing: 0) {
        HStack(spacing: 0) {
          CofficeAsset.Asset.searchLine24px.swiftUIImage
            .resizable()
            .frame(width: 24, height: 24)
            .scaledToFit()
            .padding(.trailing, 12)
          TextField("지하철, 카페 이름으로 검색", text: viewStore.binding(\.$searchText))
            .applyCofficeFont(font: .subtitle1Medium)
            .tint(CofficeAsset.Colors.grayScale9.swiftUIColor)
            .foregroundColor(CofficeAsset.Colors.grayScale9.swiftUIColor)
            .onSubmit { viewStore.send(.submitText) }
            .textFieldStyle(.plain)
            .focused($focusField, equals: .keyword)
            .keyboardType(.default)
          if viewStore.searchText.isNotEmpty {
            Button {
              viewStore.send(.clearTextButtonTapped)
            } label: {
              CofficeAsset.Asset.closeCircleFill18px.swiftUIImage
                .resizable()
                .renderingMode(.template)
                .frame(width: 18, height: 18)
                .scaledToFit()
                .foregroundColor(CofficeAsset.Colors.grayScale6.swiftUIColor)
            }
            .padding(.trailing, 8)
          } else {
            Color.clear
              .frame(width: 24, height: 24)
              .padding(.trailing, 8)
          }
          Button {
            viewStore.send(.delegate(.dismiss))
          } label: {
            CofficeAsset.Asset.close24px.swiftUIImage
          }
        }
        .padding(EdgeInsets(top: 12, leading: 20, bottom: 28, trailing: 20))
      }
      .frame(height: 64)
    }
  }

  var searchResultListView: some View {
    WithViewStore(store) { viewStore in
      ScrollView {
        VStack(spacing: 0) {
          VStack(spacing: 0) {
            ForEach(viewStore.waypoints, id: \.self) { waypoint in
              WaypointCellView(
                waypoint: waypoint,
                waypointName: waypoint.name.changeMatchTextColor(matchText: viewStore.searchText)
              )
              .contentShape(Rectangle())
              .onTapGesture { viewStore.send(.waypointCellTapped(waypoint: waypoint)) }
            }
          }
          .background(alignment: .bottom) {
            CofficeAsset.Colors.grayScale2.swiftUIColor
              .frame(height: 2)
          }
          ForEach(viewStore.cafes, id: \.self) { place in
            PlaceCellView(
              place: place,
              placeName: place.name.changeMatchTextColor(matchText: viewStore.searchText)
            )
            .onTapGesture { viewStore.send(.placeCellTapped(place: place)) }
          }
        }
        .padding(.bottom, TabBarSizePreferenceKey.defaultValue.height)
      }
    }
  }

  var searchResultEmptyView: some View {
    VStack(alignment: .center, spacing: 0) {
      Spacer()
      CofficeAsset.Asset.errorWarningFill40px.swiftUIImage
        .resizable()
        .renderingMode(.template)
        .foregroundColor(CofficeAsset.Colors.grayScale5.swiftUIColor)
        .frame(width: 40, height: 40)
        .scaledToFit()
        .padding(.bottom, 12)
      VStack(spacing: 12) {
        Text("검색결과가 없어요!")
          .applyCofficeFont(font: .header2)
          .foregroundColor(CofficeAsset.Colors.grayScale9.swiftUIColor)
          .padding(.top, 8)
        Text("다른 검색어로 다시 검색해주세요.")
          .applyCofficeFont(font: .subtitle1Medium)
          .foregroundColor(CofficeAsset.Colors.grayScale6.swiftUIColor)
          .padding(.bottom, 8)
      }
      Spacer()
    }
    .padding(.bottom, TabBarSizePreferenceKey.defaultValue.height)
  }

  var recentSearchWordsView: some View {
    WithViewStore(store) { viewStore in
      VStack(alignment: .leading, spacing: 0) {
        Text("최근검색어")
          .applyCofficeFont(font: .header3)
          .foregroundColor(CofficeAsset.Colors.grayScale9.swiftUIColor)
          .multilineTextAlignment(.leading)
          .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 16))
          .frame(maxWidth: .infinity, alignment: .leading)
          .frame(height: 60)
          .hiddenWithOpacity(isHidden: viewStore.recentSearchWordList.isEmpty)
        ScrollView(.vertical, showsIndicators: false) {
          VStack(spacing: 0) {
            ForEach(viewStore.recentSearchWordList, id: \.searchWordId) { searchWord in
              listCell(searchWord.text, searchWord.searchWordId)
                .contentShape(Rectangle())
                .onTapGesture { viewStore.send(.recentSearchWordCellTapped(recentWord: searchWord.text)) }
            }
          }
        }
      }
      .onAppear {
        viewStore.send(.onAppear)
      }
    }
  }

  func listCell(_ recentWord: String, _ id: Int) -> some View {
    WithViewStore(store) { viewStore in
      HStack(spacing: 0) {
        HStack(spacing: 16) {
          CofficeAsset.Asset.searchLine24px.swiftUIImage
            .resizable()
            .frame(width: 24, height: 24)
            .scaledToFit()
          Text(recentWord)
            .applyCofficeFont(font: .subtitleSemiBold)
            .foregroundColor(CofficeAsset.Colors.grayScale9.swiftUIColor)
        }
        .padding(EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 16))
        Spacer()
        Button {
          viewStore.send(.deleteRecentSearchWordButtonTapped(recentWordId: id))
        } label: {
          CofficeAsset.Asset.closeCircleFill18px.swiftUIImage
            .renderingMode(.template)
            .foregroundColor(CofficeAsset.Colors.grayScale6.swiftUIColor)
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
        initialState: CafeSearchCore.State(), reducer: {
          CafeSearchCore()
        }
      )
    )
  }
}
