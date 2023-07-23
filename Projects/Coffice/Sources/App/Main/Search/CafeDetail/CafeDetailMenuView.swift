//
//  CafeSearchDetailMenuView.swift
//  coffice
//
//  Created by Min Min on 2023/06/26.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct CafeDetailMenuView: View {
  private let store: StoreOf<CafeDetail>

  init(store: StoreOf<CafeDetail>) {
    self.store = store
  }

  var body: some View {
    WithViewStore(store, observe: \.selectedSubMenuType) { viewStore in
      VStack(spacing: 0) {
        cafeSubMenuButtonView

        switch viewStore.state {
        case .detailInfo:
          detailInfoMenuView
        case .review:
          reviewMenuView
        }
      }
      .padding(.top, 16)
    }
  }
}

// MARK: Menu Button

extension CafeDetailMenuView {
  private var cafeSubMenuButtonView: some View {
    WithViewStore(store, observe: \.subMenuViewStates) { viewStore in
      HStack(spacing: 0) {
        ForEach(viewStore.state) { viewState in
          Button {
            viewStore.send(.subMenuTapped(viewState.type))
          } label: {
            VStack(spacing: 0) {
              Text(viewState.title)
                .foregroundColor(viewState.foregroundColorAsset.swiftUIColor)
                .applyCofficeFont(font: .header3)
                .frame(height: 52, alignment: .center)
                .background(CofficeAsset.Colors.grayScale1.swiftUIColor)
                .padding(.horizontal, 20)
                .overlay(alignment: .bottom) {
                  viewState.bottomBorderColorAsset.swiftUIColor
                    .frame(height: 4)
                }
            }
          }
        }

        Spacer()
      }
      .frame(height: 52)
    }
  }
}

// MARK: - Detail Info Menu View

extension CafeDetailMenuView {
  private var detailInfoHeaderView: some View {
    Text("상세정보")
      .foregroundColor(CofficeAsset.Colors.grayScale9.swiftUIColor)
      .applyCofficeFont(font: .header3)
      .frame(alignment: .leading)
      .frame(height: 52)
  }

  private var detailInfoMenuView: some View {
    VStack(alignment: .leading, spacing: 0) {
      detailInfoHeaderView
      mapInfoView
      locationInfoView
      contactInfoView
      runningTimeView
      snsInfoView
    }
    .padding(.top, 10)
    .padding(.horizontal, 20)
  }

  private var snsInfoView: some View {
    WithViewStore(store) { viewStore in
      HStack {
        CofficeAsset.Asset.globalLine18px.swiftUIImage
        Button {
          viewStore.send(.cafeHomepageUrlTapped)
        } label: {
          Text(viewStore.cafe?.homepageUrl ?? "-")
            .foregroundColor(CofficeAsset.Colors.secondary1.swiftUIColor)
            .applyCofficeFont(font: .body1Medium)
            .frame(alignment: .leading)
            .frame(height: 30)
        }
      }
    }
  }

  private var mapInfoView: some View {
    WithViewStore(store) { viewStore in
      CafeDetailNaverMapView(viewStore: viewStore)
        .frame(height: 123)
    }
  }

  private var locationInfoView: some View {
    WithViewStore(store) { viewStore in
      VStack(spacing: 0) {
        HStack {
          CofficeAsset.Asset.mapPinLine18px.swiftUIImage

          Text(viewStore.cafe?.address?.address ?? "-")
            .foregroundColor(CofficeAsset.Colors.grayScale7.swiftUIColor)
            .applyCofficeFont(font: .body1Medium)
            .frame(alignment: .leading)
            .frame(height: 20)

          Button {
            UIPasteboard.general.string = viewStore.cafe?.address?.address ?? "-"
          } label: {
            CofficeAsset.Asset.fileCopyLine18px.swiftUIImage
          }

          Spacer()
        }
      }
      .frame(height: 28)
      .padding(.top, 20)
    }
  }

  private var contactInfoView: some View {
    WithViewStore(store) { viewStore in
      HStack {
        CofficeAsset.Asset.phoneFill18px.swiftUIImage
        Text(viewStore.cafe?.phoneNumber ?? "-")
          .foregroundColor(CofficeAsset.Colors.secondary1.swiftUIColor)
          .applyCofficeFont(font: .body1Medium)
          .frame(alignment: .leading)
          .frame(height: 20)
      }
      .frame(height: 28)
      .padding(.top, 4)
    }
  }

  private var runningTimeView: some View {
    WithViewStore(store) { viewStore in
      VStack(spacing: 0) {
        HStack {
          VStack {
            CofficeAsset.Asset.timeLine18px.swiftUIImage
              .padding(.top, 5)
            Spacer()
          }

          VStack(alignment: .leading, spacing: 0) {
            Button {
              viewStore.send(.toggleToPresentTextForTest)
            } label: {
              HStack(alignment: .top) {
                Text(viewStore.cafe?.openingInformation?.quickFormattedString ?? "-")
                  .foregroundColor(CofficeAsset.Colors.grayScale7.swiftUIColor)
                  .applyCofficeFont(font: .body1Medium)
                  .frame(height: 20)
                  .frame(alignment: .leading)
                  .padding(.top, 4)
                if let openingInfo = viewStore.cafe?.openingInformation,
                   openingInfo.is24Open.isFalse {
                  viewStore.runningTimeDetailInfoArrowImageAsset.swiftUIImage
                    .padding(.top, 2)
                }
              }
            }

            if viewStore.needToPresentRunningTimeDetailInfo {
              Text(viewStore.cafe?.openingInformation?.detailFormattedString ?? "-")
                .foregroundColor(CofficeAsset.Colors.grayScale7.swiftUIColor)
                .applyCofficeFont(font: .body1Medium)
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 2)
            }
          }
        }
      }
      .padding(.top, 4)
    }
  }
}

// MARK: - Review Menu View

extension CafeDetailMenuView {
  private var reviewMenuView: some View {
    WithViewStore(store) { _ in
      VStack(alignment: .leading, spacing: 0) {
        reviewHeaderView
        userReviewListView
      }
      .padding(.horizontal, 20)
    }
  }

  private var reviewHeaderView: some View {
    WithViewStore(store) { viewStore in
      HStack {
        Text(viewStore.userReviewHeaderTitle)
          .foregroundColor(CofficeAsset.Colors.grayScale8.swiftUIColor)
          .applyCofficeFont(font: .header3)
          .frame(height: 52)

        Spacer()

        Button {
          viewStore.send(.reviewWriteButtonTapped)
        } label: {
          HStack(spacing: 5) {
            Text("리뷰 쓰기")
              .foregroundColor(CofficeAsset.Colors.secondary1.swiftUIColor)
              .applyCofficeFont(font: .body2Medium)
              .padding(.vertical, 10)
              .padding(.leading, 12)
            CofficeAsset.Asset.pencilLine14px.swiftUIImage
              .renderingMode(.template)
              .foregroundColor(CofficeAsset.Colors.secondary1.swiftUIColor)
              .padding(.trailing, 10)
          }
          .overlay(
            RoundedRectangle(cornerRadius: 4)
              .stroke(CofficeAsset.Colors.grayScale4.swiftUIColor, lineWidth: 1)
          )
        }
      }
      .frame(height: 50)
    }
  }

  private var userReviewListView: some View {
    WithViewStore(store) { viewStore in
      if viewStore.userReviewCellViewStates.isNotEmpty {
        userReviewsView
      } else {
        userReviewEmptyView
      }
    }
  }

  private var userReviewsView: some View {
    WithViewStore(store) { viewStore in
      LazyVStack(spacing: 0) {
        ForEach(viewStore.userReviewCellViewStates) { viewState in
          VStack(alignment: .leading, spacing: 0) {
            VStack(spacing: 0) {
              HStack {
                VStack {
                  CofficeAsset.Asset.userProfile40px.swiftUIImage
                  Spacer()
                }

                VStack(spacing: 4) {
                  Text(viewState.userName)
                    .foregroundColor(CofficeAsset.Colors.grayScale9.swiftUIColor)
                    .applyCofficeFont(font: .subtitleSemiBold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                  Text(viewState.dateDescription)
                    .foregroundColor(CofficeAsset.Colors.grayScale7.swiftUIColor)
                    .applyCofficeFont(font: .body2Medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
                  Spacer()
                }

                Spacer()

                VStack {
                  if viewState.isMyReview {
                    Button {
                      viewStore.send(.reviewModifyButtonTapped(viewState: viewState))
                    } label: {
                      Text("수정/삭제")
                        .foregroundColor(CofficeAsset.Colors.grayScale7.swiftUIColor)
                        .applyCofficeFont(font: .body2Medium)
                    }
                  } else {
                    Button {
                      viewStore.send(.reviewReportButtonTapped(viewState: viewState))
                    } label: {
                      CofficeAsset.Asset.more2Fill24px.swiftUIImage
                    }
                  }
                  Spacer()
                }
              }
            }
            .frame(height: 42)
            .padding(.top, 20)

            Text(viewState.content)
              .foregroundColor(CofficeAsset.Colors.grayScale7.swiftUIColor)
              .applyCofficeFont(font: .body1)
              .multilineTextAlignment(.leading)
              .padding(.top, 20)

            // TODO: Tag가 한줄 넘어갈 경우 넘어가도록 커스텀 뷰 구현 필요
            if viewState.tagTypes.isNotEmpty {
              HStack(spacing: 8) {
                ForEach(viewState.tagTypes, id: \.self) { tagType in
                  Text(tagType.title)
                    .foregroundColor(CofficeAsset.Colors.grayScale7.swiftUIColor)
                    .applyCofficeFont(font: .body2Medium)
                    .frame(height: 18)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .overlay(
                      RoundedRectangle(cornerRadius: 4)
                        .stroke(
                          CofficeAsset.Colors.grayScale4.swiftUIColor,
                          lineWidth: 1
                        )
                    )
                }
              }
              .frame(height: 26)
              .padding(.top, 20)
            }

            CofficeAsset.Colors.grayScale3.swiftUIColor
              .frame(height: 1)
              .padding(.top, 16)
          }
        }
      }
    }
  }

  private var userReviewEmptyView: some View {
    WithViewStore(store, observe: \.userReviewEmptyDescription) { viewStore in
      VStack(alignment: .center) {
        Text(viewStore.state)
          .foregroundColor(CofficeAsset.Colors.grayScale7.swiftUIColor)
          .applyCofficeFont(font: .body1Medium)
          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
          .multilineTextAlignment(.center)
      }
      .frame(height: 200)
    }
  }
}

struct CafeSearchDetailMenuView_Previews: PreviewProvider {
  static var previews: some View {
    CafeDetailMenuView(
      store: .init(
        initialState: .init(cafeId: 1),
        reducer: CafeDetail()
      )
    )
  }
}
