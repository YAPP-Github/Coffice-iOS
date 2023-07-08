//
//  CafeMapCore.swift
//  Cafe
//
//  Created by sehooon on 2023/06/01.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture
import CoreLocation
import NMapsMap
import SwiftUI

extension CLLocationCoordinate2D: Equatable {
  public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
  }
}

struct CafeMapCore: ReducerProtocol {
  enum ResetState {
    case searchResultIsEmpty
    case dismissSearchResultView
  }

  enum ViewType {
    case mainMapView
    case searchView
    case searchResultView
  }

  enum FilterOrder: CaseIterable {
    case runningTime
    case outlet
    case spaceSize
    case personnel
    // TODO: 테스트용 코드로 제거 예정
    case searchDetail
    case searchList

    var title: String {
      switch self {
      case .runningTime: return "영업시간"
      case .outlet: return "콘센트"
      case .spaceSize: return "공간크기"
      case .personnel: return "인원"
        // TODO: 테스트용 코드로 제거 예정
      case .searchDetail: return "검색상세"
      case .searchList: return "검색결과"
      }
    }
  }

  enum FloatingButton: CaseIterable {
    case currentLocationButton
    case refreshButton
    case bookmarkButton

    var image: String {
      switch self {
      case .currentLocationButton:
        return "scope"
      case .bookmarkButton:
        return "bookmark"
      case .refreshButton:
        return "arrow.triangle.2.circlepath"
      }
    }
  }

  // MARK: - State
  struct State: Equatable {
    // MARK: ViewType
    var displayViewType: ViewType = .mainMapView

    // MARK: Selecting Cafe
    var selectedCafe: Cafe?
    var isSelectedCafe: Bool = false

    // MARK: Search
    var cafeSearchState = CafeSearchCore.State()
    var cafeSearchListState = CafeSearchListCore.State()
    let filterOrders = FilterOrder.allCases
    @BindingState var searchText = ""

    // MARK: NaverMapView
    var currentCameraPosition = CLLocationCoordinate2D(latitude: 37.4971, longitude: 127.0287)
    var cafeMarkerList: [Cafe] = []
    var cafeList: [Cafe] = []
    let floatingButtons = FloatingButton.allCases
    var isMovingToCurrentPosition = false
    var isUpdatingMarkers = false
    var shouldUpdateMarkers: Bool {
      return cafeMarkerList.isNotEmpty && isUpdatingMarkers
    }
    var isUpdatingBookmarkState = false
  }

  // MARK: - Action
  enum Action: Equatable, BindableAction {
    // MARK: ViewType
    case updateDisplayType(ViewType)

    // MARK: Sub-Core Actions
    case cafeSearchListAction(CafeSearchListCore.Action)
    case cafeSearchAction(CafeSearchCore.Action)

    // MARK: NaverMapView
    case floatingButtonTapped(FloatingButton)
    case updateCurrentLocation
    case updateCafeMarkers
    case cafeListResponse(TaskResult<[Cafe]>)
    case markerTapped(cafe: Cafe)
    case mapViewTapped
    case movedToCurrentPosition
    case markersUpdated
    case bookmarkStateUpdated

    // MARK: Search
    case filterOrderMenuTapped(FilterOrder)
    case requestSearchPlaceResponse(TaskResult<[Cafe]>, String)

    // MARK: Temporary
    case pushToSearchDetailForTest(cafeId: Int)
    case pushToSearchListForTest

    // MARK: Common
    case binding(BindingAction<State>)
    case requestLocationAuthorization
    case bookmarkButtonTapped(cafe: Cafe)
    case showToast(Toast.State)
    case resetResult(ResetState)
    case onDisappear
  }

  // MARK: - Dependencies
  @Dependency(\.placeAPIClient) private var placeAPIClient
  @Dependency(\.locationManager) private var locationManager
  @Dependency(\.bookmarkClient) private var bookmarkClient

  // MARK: - Body
  var body: some ReducerProtocolOf<Self> {
    BindingReducer()

    Scope(state: \.cafeSearchListState, action: /CafeMapCore.Action.cafeSearchListAction) {
      CafeSearchListCore()
    }

    Scope(state: \.cafeSearchState, action: /CafeMapCore.Action.cafeSearchAction) {
      CafeSearchCore()
    }

    Reduce { state, action in
      switch action {
        // MARK: ViewType
      case .updateDisplayType(let displayType):
        state.displayViewType = displayType
        state.cafeSearchState.previousViewType = .mainMapView
        return .none

        // MARK: Sub-Core Actions
      case .cafeSearchAction(.dismiss):
        switch state.cafeSearchState.previousViewType {
        case .mainMapView:
          state.displayViewType = .mainMapView
          return .none
        case .searchResultView:
          state.displayViewType = .searchResultView
          return .none
        default:
          return .none
        }

      case .cafeSearchListAction(.titleLabelTapped):
        state.displayViewType = .searchView
        state.cafeSearchState.previousViewType = .searchResultView
        return .none

      case .cafeSearchListAction(.dismiss):
        return .send(.resetResult(.dismissSearchResultView))

      case .cafeSearchAction(.requestSearchPlace(let searchText)):
        let title = searchText
        let latitude = state.currentCameraPosition.latitude
        let longitude = state.currentCameraPosition.longitude
        return .run { send in
          let result = await TaskResult {
            let cafeRequest = SearchPlaceRequestValue(
              searchText: searchText, userLatitude: latitude, userLongitude: longitude,
              maximumSearchDistance: 2000, isOpened: nil, hasCommunalTable: nil,
              filters: nil, pageSize: 10, pageableKey: nil
            )

            let cafeListData = try await placeAPIClient.searchPlaces(requestValue: cafeRequest)
            return cafeListData.cafes
          }
          await send(.requestSearchPlaceResponse(result, title))
        }

        // MARK: NaverMapView
      case .floatingButtonTapped(let buttonType):
        switch buttonType {
        case .currentLocationButton:
          state.isMovingToCurrentPosition = true
          return .send(.updateCurrentLocation)
        case .refreshButton:
          return .send(.updateCafeMarkers)
        case .bookmarkButton:
          return .none
        }

      case .updateCurrentLocation:
        state.currentCameraPosition = locationManager.fetchCurrentLocation()
        return .none

      case .updateCafeMarkers:
        state.isUpdatingMarkers = true
        return .run { send in
          let result = await TaskResult {
            // TODO: Sample Value를 실제 요청값으로 바꾸기
            let cafeRequest = SearchPlaceRequestValue(
              searchText: "", userLatitude: 37.498768, userLongitude: 127.0277985,
              maximumSearchDistance: 1000000, isOpened: nil, hasCommunalTable: nil,
              filters: nil, pageSize: 1000, pageableKey: nil
            )

            let cafeListData = try await placeAPIClient.searchPlaces(requestValue: cafeRequest)
            return cafeListData.cafes
          }
          await send(.cafeListResponse(result))
        }

      case .cafeListResponse(let result):
        switch result {
        case .success(let cafeList):
          state.cafeMarkerList = cafeList
          return .none
        case .failure(let error):
          debugPrint(error)
          return .none
        }

      case .markerTapped(let cafe):
        state.selectedCafe = cafe
        return .none

      case .mapViewTapped:
        state.selectedCafe = nil
        return .none

      case .movedToCurrentPosition:
        state.isMovingToCurrentPosition = false
        return .none

      case .markersUpdated:
        state.isUpdatingMarkers = false
        return .none

      case .bookmarkStateUpdated:
        state.isUpdatingBookmarkState = false
        return .none

        // MARK: Search
      case .filterOrderMenuTapped(let filterOrder):
        switch filterOrder {
        case .searchList:
          return EffectTask(value: .pushToSearchListForTest)
        case .searchDetail:
          return EffectTask(value: .pushToSearchDetailForTest(cafeId: 1))
        default:
          return .none
        }

      case .requestSearchPlaceResponse(let result, let title):
        switch result {
        case .success(let cafeList):
          if cafeList.isEmpty {
            return .send(.resetResult(.searchResultIsEmpty))
          }
          state.cafeList = cafeList
          state.cafeSearchListState.cafeList = cafeList
          guard let cafe = cafeList.first else { return .none }
          state.selectedCafe = cafe
          state.isSelectedCafe = true
          state.currentCameraPosition = CLLocationCoordinate2D(
            latitude: cafe.latitude,
            longitude: cafe.longitude
          )
          state.cafeSearchListState.title = title
          state.displayViewType = .searchResultView
          state.cafeSearchState.previousViewType = .searchResultView
          return .send(.cafeSearchAction(.dismiss))

        case .failure(let error):
          state.cafeSearchState.currentBodyType = .searchResultEmptyView
          debugPrint(error)
          return .none
        }

        // MARK: Common
      case .resetResult(let resetState):
        state.cafeList = []
        state.cafeMarkerList = []
        state.isSelectedCafe = false
        state.selectedCafe = nil
        switch resetState {
        case .searchResultIsEmpty:
          state.cafeSearchState.previousViewType = .mainMapView
          state.cafeSearchState.currentBodyType = .searchResultEmptyView
          return .none
        case .dismissSearchResultView:
          state.displayViewType = .mainMapView
          return .none
        }

      case .requestLocationAuthorization:
        locationManager.requestAuthorization()
        return .none

      case .bookmarkButtonTapped(let cafe):
        state.selectedCafe?.isBookmarked.toggle()
        state.isUpdatingBookmarkState = true
        return .run { [isBookmarked = state.selectedCafe?.isBookmarked] send in
          if isBookmarked == true {
            try await bookmarkClient.addMyPlace(placeId: cafe.placeId)
          } else {
            try await bookmarkClient.deleteMyPlace(placeId: cafe.placeId)
          }
          await send(
            .showToast(
              Toast.State(
                title: isBookmarked ?? false ? "장소가 저장되었습니다." : "장소가 저장해제되었습니다.",
                image: CofficeAsset.Asset.checkboxCircleFill18px,
                config: Config.default
              )
            )
          )
        } catch: { error, send in
          debugPrint(error)
        }

      case .onDisappear:
        // TODO: MapView쪽 리셋 작업 필요
        state.selectedCafe = nil
        return .none

      default:
        return .none
      }
    }
  }
}
