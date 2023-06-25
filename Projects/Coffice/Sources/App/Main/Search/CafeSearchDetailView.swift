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
      VStack(spacing: 0) {
        ScrollView(.vertical) {
          VStack(spacing: 0) {
            headerView
            menuContainerView
          }
          .padding(.bottom, 50)
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
      .onAppear {
        viewStore.send(.onAppear)
      }
    }
  }
}

// MARK: - Header View

extension CafeSearchDetailView {
  private var headerView: some View {
    WithViewStore(store) { viewStore in
      VStack(spacing: 0) {
        Image("cafeImage")
          .resizable()
          .frame(height: 200)
          .scaledToFit()

        VStack(spacing: 0) {
          Text("카페 이름")
            .font(.title)
            .frame(maxWidth: .infinity, alignment: .leading)

          Text("서울 용산구 ~")
            .font(.subheadline)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 5)

          HStack {
            Text("영업중")
              .padding(.all, 3)
              .font(.subheadline)
              .foregroundColor(.white)
              .background(.black)
              .cornerRadius(5)
              .padding(.top, 5)
            Text("목 09:00 ~ 21:00")
              .font(.subheadline)
              .padding(.top, 5)
            Spacer()
          }

          Divider()
            .padding(.top, 5)

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
}

// MARK: Menu View

extension CafeSearchDetailView {
  private var menuContainerView: some View {
    WithViewStore(store) { viewStore in
      VStack(spacing: 0) {
        HStack(spacing: 0) {
          ForEach(viewStore.subMenuViewStates) { viewState in
            Button {
              viewStore.send(.subMenuTapped(viewState.subMenuType))
            } label: {
              Text(viewState.subMenuType.title)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .foregroundColor(viewState.isSelected ? .white : .black)
                .background(viewState.isSelected ? .black : .white)
            }
          }
        }

        Divider()
          .padding(.horizontal, 16)

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
        homeMenuMapView
        homeMenuRunningTimeView
        homeMenuContactInfoView
        homeMenuSnsInfoView
      }
      .padding(.top, 10)
      .padding(.horizontal, 16)
    }
  }

  private var homeMenuMapView: some View {
    WithViewStore(store) { viewStore in
      Color.black
        .frame(height: 200)
    }
  }

  private var homeMenuRunningTimeView: some View {
    WithViewStore(store) { viewStore in
      VStack(spacing: 0) {
        HStack {
          Image(systemName: "mappin")
          Text("서울시 용산구 이태원로 ~ ")
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 30)
          Button {
            // TODO: 좌측 텍스트 복사 이벤트
          } label: {
            Text("복사")
              .frame(height: 30)
          }
        }
        .padding(.top, 5)

        HStack {
          VStack {
            Text("L")
              .frame(width: 24, height: 24)
              .background(
                Circle().strokeBorder(.black, lineWidth: 1)
              )
              .padding(.top, 3)
            Spacer()
          }

          VStack(spacing: 0) {
            Button {
              viewStore.send(.toggleToPresentTextForTest)
            } label: {
              HStack {
                Text("토 09:00 - 21:00")
                  .foregroundColor(.black)
                  .frame(height: 30)
                  .frame(maxWidth: .infinity, alignment: .leading)

                if viewStore.needToPresentRunningTimeDetailInfo {
                  Image(systemName: "chevron.up")
                    .tint(Color.black)
                } else {
                  Image(systemName: "chevron.down")
                    .tint(Color.black)
                }
              }
            }

            if viewStore.needToPresentRunningTimeDetailInfo {
              Text(viewStore.runningTimeDetailInfo)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
            }

            HStack {
              VStack(spacing: 0) {
                Text("- 브레이크 타임 :")
                  .font(.caption)
                Spacer()
              }

              VStack {
                Text(
                  """
                  주중) 15:00 ~ 17:00
                  주말) 15:00 ~ 16:00
                  """
                )
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                Spacer()
              }
            }
            .padding(.top, 5)

            HStack {
              VStack {
                Text("- 주문마감 :")
                  .font(.caption)
                Spacer()
              }

              VStack {
                Text(
                  """
                  주중) 마감 1시간 전
                  주말) 마감 30분 전
                  """
                )
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                Spacer()
              }
            }
          }
        }
      }
    }
  }

  private var homeMenuContactInfoView: some View {
    HStack {
      Image(systemName: "phone")
      Text("02) 123-4567")
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 30)
    }
  }

  private var homeMenuSnsInfoView: some View {
    HStack {
      Image(systemName: "network")
      Button {
        // TODO: SNS Link Action 구현 필요
      } label: {
        Text("sns nickname")
          .frame(maxWidth: .infinity, alignment: .leading)
          .frame(height: 30)
      }
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
