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
            cafeSubInfoView
            cafeSubMenuView
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
    WithViewStore(store) { _ in
      VStack(spacing: 0) {
        Image("cafeImage")
          .resizable()
          .frame(height: 200)
          .scaledToFit()

        VStack(spacing: 0) {
          HStack {
            VStack(spacing: 0) {
              Text("카페")
                .foregroundColor(.black)
                .font(.system(size: 14, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 20)
              Text("훅스턴")
                .foregroundColor(.black)
                .font(.system(size: 26, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 36)
                .padding(.top, 8)
              Text("서울 서대문구 연희로 91 2층")
                .foregroundColor(.gray)
                .font(.system(size: 14))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 4)
            }

            VStack {
              Image(systemName: "bookmark")
                .resizable()
                .frame(width: 20, height: 24)
                .padding(.top, 10)
              Spacer()
            }
          }

          HStack(spacing: 8) {
            Text("영업중")
              .foregroundColor(.brown)
              .font(.system(size: 14, weight: .bold))
              .frame(alignment: .leading)
            Text("목 09:00 ~ 21:00")
              .foregroundColor(.gray)
              .font(.system(size: 14))
            Spacer()
          }
          .padding(.top, 16)

          Divider()
            .padding(.top, 20)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
      }
    }
  }
}

// MARK: Sub Info View

extension CafeSearchDetailView {
  private var cafeSubInfoView: some View {
    WithViewStore(store) { _ in
      VStack(spacing: 0) {
        VStack(spacing: 0) {
          cafeSubPrimaryInfoView
          cafeSecondaryInfoView
        }
        .padding(.horizontal, 20)

        Color(UIColor.lightGray)
          .frame(height: 4)
          .padding(.top, 20)
      }
    }
  }

  private var cafeSubPrimaryInfoView: some View {
    WithViewStore(store, observe: \.subPrimaryInfoViewStates) { viewStore in
      VStack(alignment: .leading, spacing: 0) {
        Text("카페정보")
          .foregroundColor(.black)
          .font(.system(size: 16, weight: .bold))
          .frame(width: .infinity, alignment: .leading)
          .frame(height: 20)
          .padding(.top, 16)

        HStack {
          ForEach(viewStore.state) { viewState in
            VStack(alignment: .center, spacing: 12) {
              Image(systemName: viewState.iconName)
                .resizable()
                .frame(width: 30, height: 30)
              HStack(spacing: 8) {
                Text(viewState.title)
                  .foregroundColor(.black)
                  .font(.system(size: 14))
                  .frame(height: 20)
                Text(viewState.description)
                  .foregroundColor(.gray)
                  .font(.system(size: 14))
                  .frame(height: 20)
              }
              .fixedSize(horizontal: true, vertical: true)
            }

            if viewState.type != .groupSeat {
              Spacer()
            }
          }
          .padding(.top, 16)
        }

        Divider()
          .padding(.top, 20)
      }
    }
  }

  private var cafeSecondaryInfoView: some View {
    WithViewStore(store, observe: \.subSecondaryInfoViewStates) { viewStore in
      VStack(alignment: .leading, spacing: 0) {
        HStack {
          VStack(spacing: 0) {
            ForEach(viewStore.state) { viewState in
              Text(viewState.title)
                .foregroundColor(.black)
                .font(.system(size: 14, weight: .semibold))
                .frame(height: 20)
                .frame(maxWidth: 50, alignment: .leading)
                .padding(.bottom, 16)
            }
          }

          VStack(alignment: .leading, spacing: 0) {
            ForEach(viewStore.state) { viewState in
              HStack {
                Text(viewState.description)
                  .foregroundColor(.gray)
                  .font(.system(size: 14))
                  .frame(alignment: .leading)

                if viewState.type == .congestion {
                  Text(viewState.congestionDescription)
                    .foregroundColor(viewState.congestionLevel == .high ? .red : .black)
                    .font(.system(size: 14))

                  Spacer()

                  Text("6월 22일 16:00 기준")
                    .foregroundColor(.gray)
                    .font(.system(size: 12))
                    .frame(alignment: .trailing)
                }
              }
              .frame(height: 20)
              .padding(.bottom, 16)
            }
          }
        }
      }
      .padding(.top, 20)
    }
  }

  private var cafeSubMenuView: some View {
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
      .padding(.top, 32)
    }
  }

  private var cafeSubMenuButtonView: some View {
    WithViewStore(store, observe: \.subMenuViewStates) { viewStore in
      HStack(spacing: 0) {
        ForEach(viewStore.state) { viewState in
          Button {
            viewStore.send(.subMenuTapped(viewState.type))
          } label: {
            VStack(spacing: 0) {
              Text(viewState.title)
                .foregroundColor(viewState.isSelected ? .black : .gray)
                .font(.system(size: 16, weight: .bold))
                .frame(height: 52, alignment: .center)
                .background(.white)
                .padding(.horizontal, 20)
                .overlay(alignment: .bottom) {
                  Color.clear
                    .background(viewState.isSelected ? .black : .white)
                    .frame(height: 4)
                }
            }
          }
        }

        Spacer()
      }
    }
  }

  private var detailInfoHeaderView: some View {
    Text("상세정보")
      .foregroundColor(.black)
      .font(.system(size: 16, weight: .bold))
      .frame(width: .infinity, alignment: .leading)
      .frame(height: 52)
  }

  private var mapInfoView: some View {
    WithViewStore(store) { _ in
      Color.black
        .frame(height: 126)
    }
  }

  private var locationInfoView: some View {
    VStack(spacing: 0) {
      HStack {
        Image(systemName: "mappin")
          .frame(width: 18, height: 18)

        Text("서울 서대문구 연희로 91 2층")
          .foregroundColor(.gray)
          .font(.system(size: 14))
          .frame(alignment: .leading)
          .frame(height: 20)

        Button {
          // TODO: 좌측 텍스트 복사 이벤트
        } label: {
          Image(systemName: "doc.on.doc")
            .resizable()
            .frame(width: 18, height: 18)
            .tint(.black)
        }

        Spacer()
      }
    }
    .frame(height: 28)
    .padding(.top, 20)
  }

  private var contactInfoView: some View {
    HStack {
      Image(systemName: "phone")
        .resizable()
        .frame(width: 18, height: 18)
      Text("02) 123-4567")
        .foregroundColor(.brown)
        .font(.system(size: 14))
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 20)
    }
    .frame(height: 28)
    .padding(.top, 4)
  }

  private var runningTimeView: some View {
    WithViewStore(store) { viewStore in
      VStack(spacing: 0) {
        HStack {
          VStack {
            Image(systemName: "clock")
              .resizable()
              .frame(width: 18, height: 18)
              .tint(.black)
              .background(
                Circle().strokeBorder(.black, lineWidth: 1)
              )
            Spacer()
          }

          VStack(alignment: .leading, spacing: 0) {
            Button {
              viewStore.send(.toggleToPresentTextForTest)
            } label: {
              HStack {
                Text("월 09:00 - 21:00")
                  .foregroundColor(.gray)
                  .font(.system(size: 14))
                  .frame(height: 20)
                  .frame(alignment: .leading)

                Image(systemName: viewStore.needToPresentRunningTimeDetailInfo ? "chevron.down" : "chevron.up")
                  .resizable()
                  .scaledToFit()
                  .frame(width: 9.5)
                  .tint(.gray)
              }
            }

            // TODO: 실제 API 연동 시에 운영시간 정보 관련 뷰 모델 구성 예정
            if viewStore.needToPresentRunningTimeDetailInfo {
              Text(viewStore.runningTimeDetailInfo)
                .foregroundColor(.gray)
                .font(.system(size: 14))
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 4)
            }

            HStack {
              VStack(spacing: 0) {
                Text("- 브레이크 타임 :")
                  .foregroundColor(.gray)
                  .font(.system(size: 14))
                Spacer()
              }

              VStack {
                Text(
                  """
                  주중) 15:00 ~ 17:00
                  주말) 15:00 ~ 16:00
                  """
                )
                .foregroundColor(.gray)
                .font(.system(size: 14))
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                Spacer()
              }
            }
            .padding(.top, 5)

            HStack {
              VStack {
                Text("- 주문마감 :")
                  .foregroundColor(.gray)
                  .font(.system(size: 14))
                Spacer()
              }

              VStack {
                Text(
                  """
                  주중) 마감 1시간 전
                  주말) 마감 30분 전
                  """
                )
                .foregroundColor(.gray)
                .font(.system(size: 14))
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                Spacer()
              }
            }
          }
        }
      }
      .padding(.top, 10)
    }
  }

  private var snsInfoView: some View {
    HStack {
      Image(systemName: "network")
        .resizable()
        .frame(width: 18, height: 18)
      Button {
        // TODO: SNS Link Action 구현 필요
      } label: {
        Text("https://www.instagram.com/hoxton_seoul최대...")
          .foregroundColor(.brown)
          .font(.system(size: 14))
          .frame(maxWidth: .infinity, alignment: .leading)
          .frame(height: 30)
      }
    }
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
