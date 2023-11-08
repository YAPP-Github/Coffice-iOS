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
  private let store: StoreOf<CafeDetailMenuReducer>

  init(store: StoreOf<CafeDetailMenuReducer>) {
    self.store = store
  }

  var body: some View {
    WithViewStore(
      store,
      observe: { $0 },
      content: { viewStore in
        VStack(spacing: 0) {
          cafeSubMenuButtonView

          switch viewStore.selectedSubMenuType {
          case .detailInfo:
            detailInfoMenuView
          case .review:
            reviewMenuView
          }
        }
        .padding(.top, 16)
        .onAppear {
          viewStore.send(.onAppear)
        }
        .sheet(
          item: viewStore.binding(
            get: \.cafeReviewWriteState,
            send: { .set(\.$cafeReviewWriteState, $0) }
          ),
          content: { viewState in
            CafeReviewWriteView(
              store: store.scope(
                state: { _ in viewState },
                action: CafeDetailMenuReducer.Action.cafeReviewWrite(action:)
              )
            )
          }
        )
        .popup(
          isPresented: viewStore.binding(
            get: \.isReviewModifySheetPresented,
            send: { .set(\.$isReviewModifySheetPresented, $0) }
          ),
          view: {
            VStack(spacing: 12) {
              Button {
                viewStore.send(.reviewEditSheetButtonTapped)
              } label: {
                Text("수정하기")
                  .foregroundColor(CofficeAsset.Colors.grayScale9.swiftUIColor)
                  .applyCofficeFont(font: .button)
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .frame(height: 52)
                  .padding(.top, 20)
              }

              Button {
                viewStore.send(.reviewDeleteSheetButtonTapped)
              } label: {
                Text("삭제하기")
                  .foregroundColor(CofficeAsset.Colors.grayScale9.swiftUIColor)
                  .applyCofficeFont(font: .button)
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .frame(height: 52)
              }

              Spacer()
            }
            .padding(.horizontal, 20)
            .frame(height: 196)
            .background(CofficeAsset.Colors.grayScale1.swiftUIColor)
            .cornerRadius(12, corners: [.topLeft, .topRight])
          },
          customize: { popup in
            popup
              .type(.toast)
              .position(.bottom)
              .isOpaque(true)
              .closeOnTapOutside(true)
              .backgroundColor(CofficeAsset.Colors.grayScale10.swiftUIColor.opacity(0.4))
              .dismissCallback {
                viewStore.send(.reviewModifySheetDismissed)
              }
          }
        )
        .popup(
          isPresented: viewStore.binding(
            get: \.isReviewReportSheetPresented,
            send: { .set(\.$isReviewReportSheetPresented, $0) }
          ),
          view: {
            VStack(spacing: 12) {
              Button {
                viewStore.send(.reviewReportSheetButtonTapped)
              } label: {
                Text("신고하기")
                  .foregroundColor(CofficeAsset.Colors.grayScale9.swiftUIColor)
                  .applyCofficeFont(font: .button)
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .frame(height: 52)
                  .padding(.top, 20)
              }

              Spacer()
            }
            .padding(.horizontal, 20)
            .frame(height: 132)
            .background(CofficeAsset.Colors.grayScale1.swiftUIColor)
            .cornerRadius(12, corners: [.topLeft, .topRight])
          },
          customize: { popup in
            popup
              .type(.toast)
              .position(.bottom)
              .isOpaque(true)
              .closeOnTapOutside(true)
              .backgroundColor(CofficeAsset.Colors.grayScale10.swiftUIColor.opacity(0.4))
          }
        )
        .popup(
          item: viewStore.binding(
            get: \.deleteConfirmBottomSheetState,
            send: { .set(\.$deleteConfirmBottomSheetState, $0) }
          ),
          itemView: { sheetState in
            BottomSheetView(
              store: store.scope(
                state: { _ in sheetState },
                action: CafeDetailMenuReducer.Action.bottomSheet
              ),
              bottomSheetContent: viewStore.bottomSheetType.content
            )
          },
          customize: { BottomSheetContent.customize($0) }
        )
        .sheet(
          item: viewStore.binding(
            get: \.webViewState,
            send: { .set(\.$webViewState, $0) }
          ),
          content: { viewState in
            VStack(spacing: 0) {
              CommonWebView(
                store: store.scope(
                  state: { _ in viewState },
                  action: CafeDetailMenuReducer.Action.commonWebReducerAction
                )
              )
            }
            .customNavigationBar(
              centerView: { EmptyView() },
              leftView: { EmptyView() },
              rightView: {
                Button {
                  viewStore.send(.dismissWebView)
                } label: {
                  CofficeAsset.Asset.close40px.swiftUIImage
                }
              }
            )
          }
        )
      }
    )
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
    WithViewStore(
      store,
      observe: { $0 },
      content: { viewStore in
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
    )
  }

  private var mapInfoView: some View {
    WithViewStore(
      store,
      observe: { $0 },
      content: { viewStore in
        CafeDetailNaverMapView(viewStore: viewStore)
          .frame(height: 123)
      }
    )
  }

  private var locationInfoView: some View {
    WithViewStore(
      store,
      observe: { $0 },
      content: { viewStore in
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
              viewStore.send(.delegate(.presentToastView(message: "주소가 복사되었습니다.")))
            } label: {
              CofficeAsset.Asset.fileCopyLine18px.swiftUIImage
            }

            Spacer()
          }
        }
        .frame(height: 28)
        .padding(.top, 20)
      }
    )
  }

  private var contactInfoView: some View {
    WithViewStore(
      store,
      observe: { $0 },
      content: { viewStore in
        HStack {
          CofficeAsset.Asset.phoneFill18px.swiftUIImage

          Button {
            if let phoneNumber = viewStore.cafe?.phoneNumber {
              guard let url = URL(
                string: "tel://" + phoneNumber.replacingOccurrences(of: "-", with: "")
              )
              else { return }
              UIApplication.shared.open(url)
            }
          } label: {
            Text(viewStore.cafe?.phoneNumber ?? "-")
              .foregroundColor(CofficeAsset.Colors.secondary1.swiftUIColor)
              .applyCofficeFont(font: .body1Medium)
              .frame(alignment: .leading)
              .frame(height: 20)
          }

          Spacer()
        }
        .frame(height: 28)
        .padding(.top, 4)
      }
    )
  }

  private var runningTimeView: some View {
    WithViewStore(
      store,
      observe: { $0 },
      content: { viewStore in
        VStack(spacing: 0) {
          HStack {
            VStack {
              CofficeAsset.Asset.timeLine18px.swiftUIImage
                .padding(.top, 5)
              Spacer()
            }

            VStack(alignment: .leading, spacing: 0) {
              Button {
                viewStore.send(.toggleToPresentRunningTime)
              } label: {
                HStack(alignment: .center) {
                  Text(viewStore.cafe?.openingInformation?.quickFormattedString ?? "-")
                    .foregroundColor(CofficeAsset.Colors.grayScale7.swiftUIColor)
                    .applyCofficeFont(font: .body1Medium, lineHeight: 28)
                    .frame(alignment: .leading)

                  if let openingInfo = viewStore.cafe?.openingInformation,
                     openingInfo.is24Open.isFalse {
                    Image(viewStore.runningTimeDetailInfoArrowImageName)
                  }
                }
              }

              if viewStore.needToPresentRunningTimeDetailInfo {
                Text(viewStore.cafe?.openingInformation?.detailFormattedString ?? "-")
                  .foregroundColor(CofficeAsset.Colors.grayScale7.swiftUIColor)
                  .applyCofficeFont(font: .body1Medium, lineHeight: 28)
                  .frame(alignment: .leading)
              }
            }
          }
        }
        .padding(.top, 4)
      }
    )
  }
}

// MARK: - Review Menu View

extension CafeDetailMenuView {
  private var reviewMenuView: some View {
    WithViewStore(
      store,
      observe: { $0 },
      content: { _ in
        VStack(alignment: .leading, spacing: 0) {
          reviewHeaderView
          userReviewListView
        }
        .padding(.horizontal, 20)
      }
    )
  }

  private var reviewHeaderView: some View {
    WithViewStore(
      store,
      observe: { $0 },
      content: { viewStore in
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
    )
  }

  private var userReviewListView: some View {
    WithViewStore(
      store,
      observe: { $0 },
      content: { viewStore in
        if viewStore.userReviewCellStates.isNotEmpty {
          userReviewsView
        } else {
          userReviewEmptyView
        }
      }
    )
  }

  private var userReviewsView: some View {
    WithViewStore(
      store,
      observe: { $0 },
      content: { viewStore in
        LazyVStack(spacing: 0) {
          ForEach(viewStore.userReviewCellStates) { viewState in
            UserReviewCell(store: store, viewState: viewState)
              .onAppear {
                viewStore.send(.userReviewCellDidAppear(viewState: viewState))
              }
          }
        }
      }
    )
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

struct CafeDetailMenuView_Previews: PreviewProvider {
  static var previews: some View {
    CafeDetailMenuView(
      store: .init(
        initialState: .init(cafe: .dummy),
        reducer: {
          CafeDetailMenuReducer()
        }
      )
    )
  }
}
