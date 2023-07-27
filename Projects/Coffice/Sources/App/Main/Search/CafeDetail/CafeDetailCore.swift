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
    @BindingState var isReviewModifySheetPresented = false
    @BindingState var isReviewReportSheetPresented = false
    @BindingState var isReviewDeleteConfirmSheetPresented = false
    @BindingState var deleteConfirmBottomSheetState: BottomSheetReducer.State?
    @BindingState var toastViewMessage: String?
    @BindingState var webViewState: CommonWebReducer.State?
    var headerViewState: CafeDetailHeaderReducer.State = .init()
    var subInfoViewState: CafeDetailSubInfoReducer.State = .init()

    var cafeId: Int
    var cafe: Cafe?
    var user: User?

    var selectedUserReviewCellViewState: UserReviewCellViewState?
    var subMenuViewStates: [SubMenusViewState] = SubMenuType.allCases
      .map { SubMenusViewState.init(subMenuType: $0, isSelected: $0 == .detailInfo) }
    var userReviewCellViewStates: [UserReviewCellViewState] = []

    var selectedReviewSheetActionType: ReviewSheetButtonActionType = .none
    var bottomSheetType: BottomSheetType = .deleteConfirm
    let subMenuTypes = SubMenuType.allCases
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

    let homeMenuViewHeight: CGFloat = 100.0
    var needToPresentRunningTimeDetailInfo = false

    let userReviewEmptyDescription = """
                                     아직 리뷰가 없어요!
                                     첫 리뷰를 작성해볼까요?
                                     """
    let reviewUploadFinishedMessage = "리뷰가 등록되었습니다."
    let reviewEditFinishedMessage = "리뷰가 수정되었습니다."
    let reviewDeleteFinishedMessage = "리뷰가 삭제되었습니다."
    let reviewReportFinishedMessage = "신고가 접수되었습니다."
  }

  enum Action: Equatable, BindableAction {
    case binding(BindingAction<State>)
    case onAppear
    case placeResponse(cafe: Cafe)
    case popView
    case subMenuTapped(State.SubMenuType)
    case reviewWriteButtonTapped
    case toggleToPresentTextForTest
    case presentCafeReviewWriteView(CafeReviewWrite.State)
    case presentToastView(message: String)
    case cafeReviewWrite(action: CafeReviewWrite.Action)
    case bottomSheet(action: BottomSheetReducer.Action)
    case reviewDeleteConfirmBottomSheet(isPresented: Bool)
    case fetchPlace
    case fetchReviews
    case fetchReviewsResponse(TaskResult<[ReviewResponse]>)
    case reportReview
    case reportReviewResponse(TaskResult<HTTPURLResponse>)
    case fetchUserData
    case fetchUserDataResponse(TaskResult<User>)
    case deleteReview
    case deleteReviewResponse(TaskResult<HTTPURLResponse>)
    case updateReviewCellViewStates(reviews: [ReviewResponse])
    case reviewModifyButtonTapped(viewState: State.UserReviewCellViewState)
    case reviewModifySheet(isPresented: Bool)
    case reviewModifySheetDismissed
    case reviewReportSheet(isPresented: Bool)
    case reviewDeleteConfirmSheet(isPresented: Bool)
    case reviewEditSheetButtonTapped
    case reviewDeleteSheetButtonTapped
    case reviewReportSheetButtonTapped
    case reviewReportButtonTapped(viewState: State.UserReviewCellViewState)
    case resetSelectedReviewModifySheetActionType
    case updateLastModifiedDate

    // MARK: Cafe Detail Header
    case cafeDetailHeaderAction(CafeDetailHeaderReducer.Action)

    // MARK: Cafe Detail Sub Info
    case cafeDetailSubInfoAction(CafeDetailSubInfoReducer.Action)

    // MARK: Web View
    case commonWebReducerAction(CommonWebReducer.Action)
    case cafeHomepageUrlTapped
    case dismissWebView
  }

  @Dependency(\.accountClient) private var accountClient
  @Dependency(\.placeAPIClient) private var placeAPIClient
  @Dependency(\.reviewAPIClient) private var reviewAPIClient

  var body: some ReducerProtocolOf<CafeDetail> {
    BindingReducer()

    Scope(
      state: \.headerViewState,
      action: /Action.cafeDetailHeaderAction,
      child: {
        CafeDetailHeaderReducer()
      }
    )

    Scope(
      state: \.subInfoViewState,
      action: /Action.cafeDetailSubInfoAction,
      child: {
        CafeDetailSubInfoReducer()
      }
    )

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

      case .reportReview:
        guard let reviewId = state.selectedUserReviewCellViewState?.reviewId
        else { return .none }
        let placeId = state.cafeId

        return .run { send in
          let response = try await reviewAPIClient.reportReview(placeId: placeId, reviewId: reviewId)
          await send(.reportReviewResponse(.success(response)))
        } catch: { error, send in
          await send(.reportReviewResponse(.failure(error)))
        }

      case .deleteReview:
        guard let reviewId = state.selectedUserReviewCellViewState?.reviewId
        else { return .none }
        let placeId = state.cafeId

        return .run { send in
          let response = try await reviewAPIClient.deleteReview(placeId: placeId, reviewId: reviewId)
          await send(.deleteReviewResponse(.success(response)))
        } catch: { error, send in
          await send(.deleteReviewResponse(.failure(error)))
        }

      case .fetchReviewsResponse(let result):
        switch result {
        case .success(let reviews):
          return EffectTask(value: .updateReviewCellViewStates(reviews: reviews))
        case .failure(let error):
          debugPrint(error.localizedDescription)
        }
        return .none

      case .reportReviewResponse(let result):
        switch result {
        case .success:
          return EffectTask(value: .presentToastView(message: state.reviewReportFinishedMessage))
        case .failure(let error):
          debugPrint(error.localizedDescription)
        }
        return .none

      case .fetchUserData:
        return .run { send in
          let user = try await accountClient.fetchUserData()
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

      case .deleteReviewResponse(let result):
        switch result {
        case .success:
          return .merge(
            EffectTask(value: .presentToastView(message: state.reviewDeleteFinishedMessage)),
            EffectTask(value: .fetchReviews)
          )
        case .failure(let error):
          debugPrint(error.localizedDescription)
        }
        return .none

      case .updateReviewCellViewStates(let reviews):
        state.userReviewCellViewStates = reviews.compactMap { [userId = state.user?.id] review in
          return .init(
            reviewId: review.reviewId,
            memberId: review.memberId,
            userName: review.memberName,
            date: review.createdDate,
            content: review.content,
            tagTypes: [
              review.outletOption == .enough ? .enoughOutlets : nil,
              review.wifiOption == .fast ? .fastWifi : nil,
              review.noiseOption == .quiet ? .quiet : nil
            ]
            .compactMap { $0 },
            isMyReview: review.memberId == userId,
            outletOption: review.outletOption,
            wifiOption: review.wifiOption,
            noiseOption: review.noiseOption
          )
        }
        return .none

      case .placeResponse(let cafe):
        state.cafe = cafe
        return .merge(
          state.headerViewState.update(cafe: cafe).map(Action.cafeDetailHeaderAction),
          state.subInfoViewState.update(cafe: cafe).map(Action.cafeDetailSubInfoAction),
          EffectTask(value: .updateLastModifiedDate)
        )

      case .subMenuTapped(let menuType):
        state.selectedSubMenuType = menuType
        return .none

      case .reviewWriteButtonTapped:
        return EffectTask(
          value: .presentCafeReviewWriteView(
            .init(
              reviewType: .create,
              placeId: state.cafeId,
              imageUrlString: state.cafe?.imageUrls?.first,
              cafeName: state.cafeName,
              cafeAddress: state.cafe?.address?.address
            )
          )
        )

      case .presentCafeReviewWriteView(let viewState):
        state.cafeReviewWriteState = viewState
        return .none

      case .presentToastView(let message):
        state.toastViewMessage = message
        return .none

      case .toggleToPresentTextForTest:
        state.needToPresentRunningTimeDetailInfo.toggle()
        return .none

      case .cafeReviewWrite(let action):
        switch action {
        case .uploadReviewResponse(.success):
          return .merge(
            EffectTask(value: .presentToastView(message: state.reviewUploadFinishedMessage)),
            EffectTask(value: .fetchReviews)
          )
        case .editReviewResponse(.success):
          return .merge(
            EffectTask(value: .presentToastView(message: state.reviewEditFinishedMessage)),
            EffectTask(value: .fetchReviews)
          )
        case .dismissView:
          state.cafeReviewWriteState = nil
        default:
          return .none
        }
        return .none

      case .bottomSheet(let action):
        switch action {
        case .confirmButtonTapped:
          return .merge(
            EffectTask(value: .deleteReview),
            EffectTask(value: .reviewDeleteConfirmBottomSheet(isPresented: false))
          )
        case .cancelButtonTapped:
          return EffectTask(value: .reviewDeleteConfirmBottomSheet(isPresented: false))
        }

      case .reviewModifySheetDismissed:
        guard let cellViewState = state.selectedUserReviewCellViewState
        else { return .none }

        var popActionEffectTask: EffectTask<Action> = .none

        switch state.selectedReviewSheetActionType {
        case .edit:
          popActionEffectTask = EffectTask(
            value: .presentCafeReviewWriteView(
              .init(
                reviewType: .edit,
                placeId: state.cafeId,
                imageUrlString: state.cafe?.imageUrls?.first,
                reviewId: cellViewState.reviewId,
                cafeName: state.cafeName,
                cafeAddress: state.cafe?.address?.address,
                outletOption: cellViewState.outletOption,
                wifiOption: cellViewState.wifiOption,
                noiseOption: cellViewState.noiseOption,
                reviewText: cellViewState.content
              )
            )
          )
          .delay(for: 0.1, scheduler: DispatchQueue.main)
          .eraseToEffect()
        case .delete:
          return EffectTask(value: .reviewDeleteConfirmBottomSheet(isPresented: true))
            .delay(for: 0.1, scheduler: DispatchQueue.main)
            .eraseToEffect()
        default:
          return .none
        }

        return .merge(
          popActionEffectTask,
          EffectTask(value: .resetSelectedReviewModifySheetActionType)
        )

      case .reviewModifySheet(let isPresented):
        state.isReviewModifySheetPresented = isPresented
        return .none

      case .reviewReportSheet(let isPresented):
        state.isReviewReportSheetPresented = isPresented
        return .none

      case .reviewDeleteConfirmSheet(let isPresented):
        state.isReviewDeleteConfirmSheetPresented = isPresented
        return .none

      case .reviewDeleteConfirmBottomSheet(let isPresented):
        if isPresented {
          state.deleteConfirmBottomSheetState = .init()
        } else {
          state.deleteConfirmBottomSheetState = nil
        }
        return .none

      case .reviewModifyButtonTapped(let viewState):
        state.selectedUserReviewCellViewState = viewState
        return EffectTask(value: .reviewModifySheet(isPresented: true))

      case .reviewEditSheetButtonTapped:
        state.selectedReviewSheetActionType = .edit
        return EffectTask(value: .reviewModifySheet(isPresented: false))

      case .reviewDeleteSheetButtonTapped:
        state.selectedReviewSheetActionType = .delete
        return EffectTask(value: .reviewModifySheet(isPresented: false))

      case .reviewReportSheetButtonTapped:
        state.selectedReviewSheetActionType = .report
        return .merge(
          EffectTask(value: .reviewReportSheet(isPresented: false)),
          EffectTask(value: .reportReview)
        )

      case .reviewReportButtonTapped(let viewState):
        state.selectedUserReviewCellViewState = viewState
        return EffectTask(value: .reviewReportSheet(isPresented: true))

      case .resetSelectedReviewModifySheetActionType:
        state.selectedReviewSheetActionType = .none
        return .none

      case .cafeHomepageUrlTapped:
        guard let webViewUrlString = state.cafe?.homepageUrl
        else { return .none }

        state.webViewState = .init(urlString: webViewUrlString)
        return .none

      case .dismissWebView:
        state.webViewState = nil
        return .none

        // MARK: Cafe Detail Header
      case .cafeDetailHeaderAction(.delegate(let action)):
        switch action {
        case .presentToastView(message: let message):
          return EffectTask(value: .presentToastView(message: message))
        case .fetchPlace:
          return EffectTask(value: .fetchPlace)
        case .updateBookmarkedState(let isBookmarked):
          state.cafe?.isBookmarked = isBookmarked
          return .none
        }

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
    .ifLet(
      \.webViewState,
      action: /Action.commonWebReducerAction
    ) {
      CommonWebReducer()
    }
  }
}

// MARK: - Getter

extension CafeDetail.State {
  var cafeName: String {
    cafe?.name ?? "-"
  }

  var openingStateDescription: String {
    cafe?.openingInformation?.isOpened ?? false
    ? "영업중" : "영업종료"
  }

  var todayRunningTimeDescription: String {
    cafe?.openingInformation?.quickFormattedString ?? "-"
  }

  var userReviewHeaderTitle: String {
    return "리뷰 \(userReviewCellViewStates.count)"
  }

  var runningTimeDetailInfoArrowImageAsset: CofficeImages {
    return needToPresentRunningTimeDetailInfo
    ? CofficeAsset.Asset.arrowDropUpLine24px
    : CofficeAsset.Asset.arrowDropDownLine24px
  }
}

// MARK: - Sub Views State

extension CafeDetail.State {
  struct UserReviewCellViewState: Hashable, Identifiable {
    let id = UUID()
    let reviewId: Int
    let memberId: Int
    let userName: String
    let date: Date?
    let content: String
    let tagTypes: [ReviewTagType]
    let isMyReview: Bool
    let outletOption: ReviewOption.OutletOption
    let wifiOption: ReviewOption.WifiOption
    let noiseOption: ReviewOption.NoiseOption

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

extension CafeDetail {
  enum ReviewSheetButtonActionType {
    case edit
    case delete
    case report
    case none
  }
}

extension CafeDetail {
  enum BottomSheetType {
    case deleteConfirm

    var content: BottomSheetContent {
      switch self {
      case .deleteConfirm:
        return .init(
          title: "정말로 삭제하시나요?",
          description: "삭제한 내용은 다시 되돌릴 수 없어요!",
          confirmButtonTitle: "삭제하기",
          cancelButtonTitle: "취소하기"
        )
      }
    }
  }
}
