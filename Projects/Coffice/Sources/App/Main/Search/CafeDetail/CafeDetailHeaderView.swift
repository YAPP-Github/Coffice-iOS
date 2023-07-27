//
//  CafeSearchDetailHeaderView.swift
//  coffice
//
//  Created by Min Min on 2023/06/26.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import Kingfisher
import SwiftUI

struct CafeDetailHeaderView: View {
  private let store: StoreOf<CafeDetailHeaderReducer>

  init(store: StoreOf<CafeDetailHeaderReducer>) {
    self.store = store
  }

  var body: some View {
    WithViewStore(store) { viewStore in
      VStack(spacing: 0) {
        imagePageView

        VStack(spacing: 0) {
          HStack {
            VStack(spacing: 0) {
              Text("카페")
                .foregroundColor(CofficeAsset.Colors.grayScale9.swiftUIColor)
                .applyCofficeFont(font: .button)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 20)
              Text(viewStore.cafeName)
                .foregroundColor(CofficeAsset.Colors.grayScale9.swiftUIColor)
                .applyCofficeFont(font: .header0)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 36)
                .padding(.top, 8)
              Text(viewStore.cafeAddress)
                .foregroundColor(CofficeAsset.Colors.grayScale7.swiftUIColor)
                .applyCofficeFont(font: .body1Medium)
                .font(.system(size: 14))
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 20)
                .padding(.top, 4)
            }

            VStack {
              Button {
                viewStore.send(.bookmarkButtonTapped)
              } label: {
                viewStore.bookmarkButtonImage.swiftUIImage
              }
              Spacer()
            }
          }

          HStack(spacing: 8) {
            Text(viewStore.openingStateDescription)
              .foregroundColor(CofficeAsset.Colors.secondary1.swiftUIColor)
              .applyCofficeFont(font: .button)
              .frame(alignment: .leading)
            Text(viewStore.todayRunningTimeDescription)
              .foregroundColor(CofficeAsset.Colors.grayScale7.swiftUIColor)
              .applyCofficeFont(font: .body1Medium)
            Spacer()
          }
          .padding(.top, 16)

          CofficeAsset.Colors.grayScale3.swiftUIColor
            .frame(height: 1)
            .padding(.top, 21)
        }
        .padding(EdgeInsets(top: 20, leading: 20, bottom: 16, trailing: 20))
      }
    }
  }
}

extension CafeDetailHeaderView {
  private var imagePageView: some View {
    WithViewStore(store) { viewStore in
      Group {
        if let imageUrls = viewStore.cafe?.imageUrls,
           imageUrls.isNotEmpty {
          TabView {
            ForEach(imageUrls, id: \.self) { imageUrl in
              KFImage.url(URL(string: imageUrl))
                .placeholder {
                  imagePlaceholderView
                }
                .resizable()
                .scaledToFill()
            }
          }
          .tabViewStyle(PageTabViewStyle())
        } else {
          imagePlaceholderView
        }
      }
      .frame(height: viewStore.imagePageViewHeight)
    }
  }

  private var imagePlaceholderView: some View {
    LinearGradient(
      gradient: Gradient(colors: [.black.opacity(0.06), .black.opacity(0.3)]),
      startPoint: .top,
      endPoint: .bottom
    )
    .background(alignment: .center) {
      CofficeAsset.Asset.icPlaceholder.swiftUIImage
        .padding(.top, UIApplication.keyWindow?.safeAreaInsets.top ?? 0.0)
    }
  }
}

struct CafeDetailHeaderView_Previews: PreviewProvider {
  static var previews: some View {
    CafeDetailHeaderView(
      store: .init(
        initialState: .init(cafe: .dummy),
        reducer: CafeDetailHeaderReducer()
      )
    )
  }
}

extension CafeDetailHeaderReducer.State {
  var cafeName: String {
    cafe?.name ?? "-"
  }

  var cafeAddress: String {
    cafe?.address?.address ?? "-"
  }

  var openingStateDescription: String {
    cafe?.openingInformation?.isOpened ?? false
    ? "영업중" : "영업종료"
  }

  var todayRunningTimeDescription: String {
    cafe?.openingInformation?.quickFormattedString ?? "-"
  }

  var bookmarkButtonImage: CofficeImages {
    return cafe?.isBookmarked ?? false
    ? CofficeAsset.Asset.bookmarkFill40px
    : CofficeAsset.Asset.bookmarkLine40px
  }
}

struct CafeDetailHeaderReducer: ReducerProtocol {
  struct State: Equatable {
    var cafe: Cafe?
    let bookmarkedMessage = "장소가 저장되었습니다."
    let imagePageViewHeight: CGFloat = 346.0

    mutating func update(cafe: Cafe?) -> EffectTask<Action> {
      self.cafe = cafe
      return .none
    }
  }

  enum Action: Equatable {
    case bookmarkButtonTapped
    case addMyPlace
    case addMyPlaceFinished
    case deleteMyPlace
    case delegate(Delegate)
  }

  enum Delegate: Equatable {
    case presentToastView(message: String)
    case fetchPlace
    case updateBookmarkedState(Bool)
  }

  @Dependency(\.bookmarkClient) private var bookmarkAPIClient

  var body: some ReducerProtocolOf<CafeDetailHeaderReducer> {
    Reduce { state, action in
      switch action {
      case .bookmarkButtonTapped:
        state.cafe?.isBookmarked.toggle()
        let isBookmarked = state.cafe?.isBookmarked ?? false

        if isBookmarked {
          return .merge(
            EffectTask(value: .delegate(.updateBookmarkedState(isBookmarked))),
            EffectTask(value: .addMyPlace)
          )
        } else {
          return .merge(
            EffectTask(value: .delegate(.updateBookmarkedState(isBookmarked))),
            EffectTask(value: .deleteMyPlace)
          )
        }

      case .addMyPlace:
        guard let placeId = state.cafe?.placeId
        else { return .none }

        return .run { send in
          try await bookmarkAPIClient.addMyPlace(placeId: placeId)
          await send(.addMyPlaceFinished)
        } catch: { error, send in
          debugPrint(error)
        }

      case .addMyPlaceFinished:
        let bookmarkedMessage = state.bookmarkedMessage

        return .merge(
          EffectTask(value: .delegate(.fetchPlace)),
          EffectTask(value: .delegate(.presentToastView(message: bookmarkedMessage)))
        )

      case .deleteMyPlace:
        guard let placeId = state.cafe?.placeId
        else { return .none }

        return .run { send in
          try await bookmarkAPIClient.deleteMyPlace(placeId: placeId)
          await send(.delegate(.fetchPlace))
        } catch: { error, send in
          debugPrint(error)
        }

      default:
        return .none
      }
    }
  }
}
