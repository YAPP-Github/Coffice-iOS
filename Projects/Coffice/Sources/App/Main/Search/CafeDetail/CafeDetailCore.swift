//
//  CafeDetailCore.swift
//  coffice
//
//  Created by Min Min on 2023/06/24.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import Foundation

struct CafeDetail: ReducerProtocol {
  struct State: Equatable {
    @BindingState var cafeReviewWriteState: CafeReviewWrite.State?
    var cafeId: Int
    var cafe: Cafe?
    var cafeTestImageAssets: [CofficeImages] = [
      CofficeAsset.Asset.cafeImage,
      CofficeAsset.Asset.userProfile40px,
      CofficeAsset.Asset.errorWarningFill40px
    ]
    // TODO: User data 처리방식 고민 필요
    var user: User?

    let subMenuTypes = SubMenuType.allCases
    var subMenuViewStates: [SubMenusViewState] = SubMenuType.allCases
      .map { SubMenusViewState.init(subMenuType: $0, isSelected: $0 == .detailInfo) }
    var subPrimaryInfoViewStates: [SubPrimaryInfoViewState] = SubPrimaryInfoType.allCases
      .map(SubPrimaryInfoViewState.init)
    var subSecondaryInfoViewStates: [SubSecondaryInfoViewState] = SubSecondaryInfoType.allCases
      .map(SubSecondaryInfoViewState.init)
    var userReviewCellViewStates: [UserReviewCellViewState] = []
    var userReviewHeaderTitle: String {
      return "리뷰 \(userReviewCellViewStates.count)"
    }

    var selectedSubMenuType: SubMenuType = .detailInfo {
      didSet {
        subMenuViewStates = SubMenuType.allCases.map { subMenuType in
          SubMenusViewState(
            subMenuType: subMenuType,
            isSelected: subMenuType == selectedSubMenuType
          )
        }
      }
    }

    let imagePageViewHeight: CGFloat = 346.0
    let homeMenuViewHeight: CGFloat = 100.0
    let openTimeDescription = """
                              화 09:00 - 21:00
                              수 09:00 - 21:00
                              목 09:00 - 21:00
                              금 정기휴무 (매주 금요일)
                              토 09:00 - 21:00
                              일 09:00 - 21:00
                              """
    var runningTimeDetailInfo = ""
    var needToPresentRunningTimeDetailInfo = false
    var runningTimeDetailInfoArrowImageAsset: CofficeImages {
      return needToPresentRunningTimeDetailInfo
      ? CofficeAsset.Asset.arrowDropUpLine24px
      : CofficeAsset.Asset.arrowDropDownLine24px
    }

    let userReviewEmptyDescription: String = """
                                             아직 리뷰가 없어요!
                                             첫 리뷰를 작성해볼까요?
                                             """
  }

  enum Action: Equatable, BindableAction {
    case binding(BindingAction<State>)
    case onAppear
    case placeResponse(cafe: Cafe)
    case popView
    case subMenuTapped(State.SubMenuType)
    case reviewWriteButtonTapped
    case toggleToPresentTextForTest
    case infoGuideButtonTapped(CafeFilter.GuideType)
    case presentBubbleMessageView(BubbleMessage.State)
    case presentCafeReviewWriteView(CafeReviewWrite.State)
    case cafeReviewWrite(action: CafeReviewWrite.Action)
    case fetchPlace
    case fetchReviews
    case fetchReviewsResponse(TaskResult<[ReviewResponse]>)
    case fetchUserData
    case fetchUserDataResponse(TaskResult<User>)
    case updateReviewCellViewStates(reviews: [ReviewResponse])
  }

  @Dependency(\.loginClient) private var loginClient
  @Dependency(\.placeAPIClient) private var placeAPIClient
  @Dependency(\.reviewAPIClient) private var reviewAPIClient

  var body: some ReducerProtocolOf<CafeDetail> {
    BindingReducer()

    Reduce { state, action in
      switch action {
      case .onAppear:
        return .merge(
          EffectTask(value: .fetchUserData),
          EffectTask(value: .fetchPlace),
          EffectTask(value: .fetchReviews)
        )

      case .fetchPlace:
        return .run { [cafeId = state.cafeId] send in
          let cafe = try await placeAPIClient.fetchPlace(placeId: cafeId)
          await send(.placeResponse(cafe: cafe))
        } catch: { error, send in
          debugPrint(error)
        }

      case .fetchReviews:
        return .run { [placeId = state.cafeId] send in
          let reviews = try await reviewAPIClient.fetchReviews(requestValue: .init(placeId: placeId))
          await send(.fetchReviewsResponse(.success(reviews)))
        } catch: { error, send in
          await send(.fetchReviewsResponse(.failure(error)))
        }

      case .fetchReviewsResponse(let result):
        switch result {
        case .success(let reviews):
          return EffectTask(value: .updateReviewCellViewStates(reviews: reviews))
        case .failure(let error):
          debugPrint(error.localizedDescription)
        }
        return .none

      case .fetchUserData:
        return .run { send in
          let user = try await loginClient.fetchUserData()
          await send(.fetchUserDataResponse(.success(user)))
        } catch: { error, send in
          await send(.fetchUserDataResponse(.failure(error)))
        }

      case .fetchUserDataResponse(let result):
        switch result {
        case .success(let user):
          state.user = user
        case .failure(let error):
          debugPrint(error.localizedDescription)
        }
        return .none

      case .updateReviewCellViewStates(let reviews):
        state.userReviewCellViewStates = reviews.compactMap { review in
          return .init(
            userName: review.memberName,
            date: review.createdDate,
            content: review.content,
            tagTypes: [
              review.outletOption == .enough ? .enoughOutlets : nil,
              review.wifiOption == .fast ? .fastWifi : nil,
              review.noiseOption == .quiet ? .quiet : nil
            ]
            .compactMap { $0 }
          )
        }
        return .none

      case .placeResponse(let cafe):
        state.cafe = cafe
        return .none

      case .subMenuTapped(let menuType):
        state.selectedSubMenuType = menuType
        return .none

      case .reviewWriteButtonTapped:
        return EffectTask(value: .presentCafeReviewWriteView(.init(reviewType: .create, placeId: state.cafeId)))

      case .presentCafeReviewWriteView(let viewState):
        state.cafeReviewWriteState = viewState
        return .none

      case .toggleToPresentTextForTest:
        state.needToPresentRunningTimeDetailInfo.toggle()

        if state.needToPresentRunningTimeDetailInfo {
          state.runningTimeDetailInfo = state.openTimeDescription
        } else {
          state.runningTimeDetailInfo = ""
        }
        return .none

      case .infoGuideButtonTapped(let guideType):
        return EffectTask(
          value: .presentBubbleMessageView(
            .init(guideType: guideType)
          )
        )

      case .cafeReviewWrite(let action):
        switch action {
        case .uploadReviewResponse(.success):
          return EffectTask(value: .fetchReviews)
        case .dismissView:
          state.cafeReviewWriteState = nil
        default:
          return .none
        }
        return .none

      default:
        return .none
      }
    }
    .ifLet(
      \.cafeReviewWriteState,
      action: /Action.cafeReviewWrite(action:)
    ) {
      CafeReviewWrite()
    }
  }
}

// MARK: - Sub Views State

extension CafeDetail.State {
  struct UserReviewCellViewState: Equatable, Identifiable {
    let id = UUID()
    let userName: String
    let date: Date?
    let content: String
    let tagTypes: [ReviewTagType]

    var dateDescription: String {
      guard let date else { return "-" }

      let dateFormatter = DateFormatter()
      dateFormatter.locale = Locale(identifier: "ko_KR")
      dateFormatter.dateFormat = "M.dd E"
      return dateFormatter.string(from: date)
    }
  }

  enum SubMenuType: CaseIterable {
    case detailInfo
    case review
  }

  enum SubPrimaryInfoType: CaseIterable {
    case outletState
    case spaceSize
    case groupSeat
  }

  enum SubSecondaryInfoType: CaseIterable {
    case food
    case toilet
    case beverage
    case price
    case congestion
  }

  enum CongestionLevel {
    case low
    case middle
    case high
  }

  enum ReviewTagType: CaseIterable {
    case enoughOutlets
    case fastWifi
    case quiet

    var title: String {
      switch self {
      case .enoughOutlets:
        return "🔌 콘센트 넉넉해요"
      case .fastWifi:
        return "📶 와이파이 빨라요"
      case .quiet:
        return "🔊 조용해요"
      }
    }
  }

  struct SubPrimaryInfoViewState: Identifiable, Equatable {
    let id = UUID()
    let type: SubPrimaryInfoType
    var description = "-"

    init(type: SubPrimaryInfoType) {
      self.type = type

      description = "-"

      switch type {
      case .outletState:
        description = "넉넉"
      case .spaceSize:
        description = "대형"
      case .groupSeat:
        description = "있음"
      }
    }

    var title: String {
      switch type {
      case .outletState: return "콘센트"
      case .spaceSize: return "공간 크기"
      case .groupSeat: return "단체석"
      }
    }

    var iconName: String {
      switch type {
      case .outletState: return "power"
      case .spaceSize: return "house"
      case .groupSeat: return "person"
      }
    }

    var guideType: CafeFilter.GuideType {
      switch type {
      case .outletState: return .outletState
      case .spaceSize: return .spaceSize
      case .groupSeat: return .groupSeat
      }
    }
  }

  struct SubSecondaryInfoViewState: Identifiable, Equatable {
    let id = UUID()
    let type: SubSecondaryInfoType
    var description = "-"
    var congestionLevel: CongestionLevel

    init(type: SubSecondaryInfoType) {
      self.type = type

      congestionLevel = .high
      description = "-"

      switch type {
      case .food:
        description = "디저트 / 식사가능"
      case .toilet:
        description = "실내 / 남녀개별"
      case .beverage:
        description = "디카페인 / 두유"
      case .price:
        description = "아메리카노 4000원~"
      case .congestion:
        description = "평일 오후"
      }
    }

    var title: String {
      switch type {
      case .food: return "푸드"
      case .toilet: return "화장실"
      case .beverage: return "음료"
      case .price: return "가격대"
      case .congestion: return "혼잡도"
      }
    }

    var congestionDescription: String {
      switch congestionLevel {
      case .low: return "여유"
      case .middle: return "보통"
      case .high: return "혼잡"
      }
    }
  }

  struct SubMenusViewState: Identifiable, Equatable {
    let id = UUID()
    let type: SubMenuType
    let isSelected: Bool
    var foregroundColorAsset: CofficeColors {
      isSelected ? CofficeAsset.Colors.grayScale9 : CofficeAsset.Colors.grayScale5
    }

    var bottomBorderColorAsset: CofficeColors {
      isSelected ? CofficeAsset.Colors.grayScale9 : CofficeAsset.Colors.grayScale1
    }

    init(subMenuType: SubMenuType, isSelected: Bool = false) {
      self.type = subMenuType
      self.isSelected = isSelected
    }

    var title: String {
      switch type {
      case .detailInfo: return "세부정보"
      case .review: return "리뷰"
      }
    }
  }
}
