//
//  CafeSearchDetailMenuView.swift
//  coffice
//
//  Created by Min Min on 2023/06/26.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct CafeSearchDetailMenuView: View {
  private let store: StoreOf<CafeSearchDetail>

  init(store: StoreOf<CafeSearchDetail>) {
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
      .padding(.top, 32)
    }
  }
}

// MARK: Menu Button

extension CafeSearchDetailMenuView {
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
}

// MARK: - Detail Info Menu View

extension CafeSearchDetailMenuView {
  private var detailInfoHeaderView: some View {
    Text("상세정보")
      .foregroundColor(.black)
      .font(.system(size: 16, weight: .bold))
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
          .frame(alignment: .leading)
          .frame(height: 30)
      }
    }
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
        .frame(alignment: .leading)
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

                Image(systemName: viewStore.needToPresentRunningTimeDetailInfo ? "chevron.up" : "chevron.down")
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
}

// MARK: - Review Menu View

extension CafeSearchDetailMenuView {
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
    WithViewStore(store) { _ in
      HStack {
        Text("리뷰 10")
          .foregroundColor(.black)
          .font(.system(size: 16, weight: .bold))
          .frame(height: 52)

        Spacer()

        Button {
          // TODO: 리뷰쓰기 이벤트 구현 필요
        } label: {
          HStack(spacing: 5) {
            Text("리뷰 쓰기")
              .foregroundColor(.brown)
              .font(.system(size: 12))
              .padding(.vertical, 10)
              .padding(.leading, 10)
            Image(systemName: "pencil")
              .resizable()
              .frame(width: 10.5, height: 10.5)
              .padding(.trailing, 10)
              .tint(.brown)
          }
          .overlay(
            RoundedRectangle(cornerRadius: 4)
              .stroke(.gray, lineWidth: 1)
          )
        }
      }
      .frame(height: 50)
    }
  }

  private var userReviewListView: some View {
    WithViewStore(store) { _ in
      VStack(spacing: 0) {
        ForEach(0..<10) { _ in
          userReviewCell
        }
      }
    }
  }

  private var userReviewCell: some View {
    WithViewStore(store) { _ in
      VStack(alignment: .leading, spacing: 0) {
        VStack(spacing: 0) {
          HStack {
            VStack {
              Image(systemName: "person.crop.circle")
                .resizable()
                .frame(width: 36, height: 36)
              Spacer()
            }

            VStack(spacing: 4) {
              Text("수민")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
              Text("5.24 토")
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
              Spacer()
            }

            Spacer()

            VStack {
              Button {
                // TODO: 수정/삭제 & 신고하기 이벤트 구현 필요
              } label: {
                if Int.random(in: 0...1) == 0 {
                  Image(systemName: "ellipsis")
                    .resizable()
                    .scaledToFit()
                    .rotationEffect(.degrees(90))
                    .frame(width: 18)
                    .tint(.black)
                } else {
                  Text("수정/삭제")
                    .foregroundColor(.gray)
                    .font(.system(size: 12))
                }
              }
              Spacer()
            }
          }
        }
        .frame(height: 42)
        .padding(.top, 20)

        Text(
          """
          카페 공부 하기에 넘 좋았어요! 라떼, 버터바가 특히 맛있어요.
          오후엔 사람이 꽉차니 일찍오는 것 추천!
          """
        )
        .foregroundColor(.gray)
        .font(.system(size: 14))
        .multilineTextAlignment(.leading)
        .padding(.top, 20)

        // TODO: Tag기 한줄 넘어갈 경우 표출 사양 확인 필요
        HStack(spacing: 8) {
          ForEach(CafeSearchDetail.State.ReviewTagType.allCases, id: \.self) { tagType in
            HStack(spacing: 4) {
              Image(systemName: tagType.iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 12)
                .padding(.leading, 8)
              Text(tagType.title)
                .foregroundColor(.gray)
                .font(.system(size: 12))
                .frame(height: 18)
                .padding(.vertical, 4)
                .padding(.trailing, 8)
            }
            .overlay(
              RoundedRectangle(cornerRadius: 4).stroke(.gray, lineWidth: 1)
            )
          }
        }
        .padding(.top, 20)

        Divider()
          .padding(.top, 16)
      }
    }
  }
}

struct CafeSearchDetailMenuView_Previews: PreviewProvider {
  static var previews: some View {
    CafeSearchDetailMenuView(
      store: .init(
        initialState: .init(),
        reducer: CafeSearchDetail()
      )
    )
  }
}
