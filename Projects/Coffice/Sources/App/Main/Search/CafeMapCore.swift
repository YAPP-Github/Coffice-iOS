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

  enum BottomFloatingButton: CaseIterable {
    case bookmarkButton
    case currentLocationButton

    var image: Image {
      switch self {
      case .bookmarkButton:
        return CofficeAsset.Asset.bookmarkFill36px.swiftUIImage
      case .currentLocationButton:
        return CofficeAsset.Asset.navigationFill36px.swiftUIImage
      }
    }
  }

  // MARK: - State
  struct State: Equatable {
    // MARK: CardViewUI
    var maxScreenWidth: CGFloat = .zero
    var fixedImageSize: CGFloat { (maxScreenWidth - 56) / 3 }
    var fixedCardTitleSize: CGFloat { maxScreenWidth - 48 }

    // MARK: ViewType
    var displayViewType: ViewType = .mainMapView

    // MARK: Selecting Cafe
    var selectedCafe: Cafe?
    var isSelectedCafe: Bool = false

    // MARK: Search
    @BindingState var searchText = ""
    var cafeSearchState = CafeSearchCore.State()
    var cafeSearchListState: CafeSearchListCore.State = .init()
    var cafeFilterMenusState: CafeFilterMenus.State = .mock

    // MARK: CafeFilter
    var cafeFilterInformation: CafeFilterInformation = .mock

    // MARK: NaverMapView
    var currentCameraPosition = CLLocationCoordinate2D(latitude: 37.4971, longitude: 127.0287)
    var cafeMarkerList: [Cafe] = []
    var cafeList: [Cafe] = []
    var shouldClearMarkers: Bool = false
    let bottomFloatingButtons = BottomFloatingButton.allCases
    var isMovingToCurrentPosition = false
    var isUpdatingMarkers = false
    var shouldUpdateMarkers: Bool {
      return cafeMarkerList.isNotEmpty && isUpdatingMarkers
    }
    var isUpdatingBookmarkState = false
    var shouldShowRefreshButtonView: Bool {
      return isMovingCameraPosition.isFalse && cameraUpdateReason != .changedByDeveloper
    }
    var isMovingCameraPosition = false
    var cameraUpdateReason: NaverMapCameraUpdateReason = .changedByDeveloper
  }

  // MARK: - Action
  enum Action: Equatable, BindableAction {
    // MARK: ViewType
    case updateDisplayType(ViewType)
    case updateMaxScreenWidth(CGFloat)

    // MARK: Sub-Core Actions
    case cafeSearchListAction(CafeSearchListCore.Action)
    case cafeSearchAction(CafeSearchCore.Action)

    // MARK: NaverMapView
    case bottomFloatingButtonTapped(BottomFloatingButton)
    case updateCurrentLocation
    case updateCafeMarkers
    case cafeListResponse(TaskResult<[Cafe]>)
    case markerTapped(cafe: Cafe)
    case mapViewTapped
    case movedToCurrentPosition
    case markersUpdated
    case bookmarkStateUpdated
    case cleardMarkers
    case refreshButtonTapped
    case updateCameraUpdateReason(NaverMapCameraUpdateReason)
    case cameraPositionMoved

    // MARK: Search
    case infiniteScrollSearchPlaceResponse(TaskResult<CafeSearchResponse>)
    case requestSearchPlaceResponse(TaskResult<CafeSearchResponse>, String)

    // MARK: Temporary
    case pushToSearchDetailForTest(cafeId: Int)
    case pushToSearchListForTest

    // MARK: Common
    case binding(BindingAction<State>)
    case requestLocationAuthorization
    case bookmarkButtonTapped(cafe: Cafe)
    case showToast(Toast.State)
    case resetResult(ResetState)
    case cafeFilterMenus(action: CafeFilterMenus.Action)
    case updateCafeFilter(information: CafeFilterInformation)
    case filterBottomSheetDismissed
    case onDisappear
  }

  // MARK: - Dependencies
  @Dependency(\.placeAPIClient) private var placeAPIClient
  @Dependency(\.locationManager) private var locationManager
  @Dependency(\.bookmarkClient) private var bookmarkClient

  // MARK: - Body
  var body: some ReducerProtocolOf<Self> {
    BindingReducer()

    Scope(
      state: \.cafeFilterMenusState,
      action: /Action.cafeFilterMenus(action:)
    ) {
      CafeFilterMenus()
    }

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

      case .updateMaxScreenWidth(let width):
        state.maxScreenWidth = width
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
        let cameraPosition = state.currentCameraPosition
        state.cafeSearchState.searchTextSnapshot = searchText
        state.cafeSearchState.searchCameraPositionSnapshot = state.currentCameraPosition
        return .run { send in
          let result = await TaskResult {
            let cafeRequest = SearchPlaceRequestValue(
              searchText: searchText, userLatitude: cameraPosition.latitude,
              userLongitude: cameraPosition.longitude, maximumSearchDistance: 2000,
              isOpened: nil, hasCommunalTable: nil, filters: nil, pageSize: 10, pageableKey: nil
            )
            let cafeSearchResponose = try await placeAPIClient.searchPlaces(requestValue: cafeRequest)
            return cafeSearchResponose
          }
          await send(.requestSearchPlaceResponse(result, title))
        }

      case .cafeSearchListAction(.scrollAndRequestSearchPlace(let lastDistance)):
        guard let cameraPosition = state.cafeSearchState.searchCameraPositionSnapshot
        else { return .none }
        let pageSize = state.cafeSearchListState.pageSize
        let searchText = state.cafeSearchState.searchTextSnapshot
        return .run { send in
          let result = await TaskResult {
            let cafeRequest = SearchPlaceRequestValue(
              searchText: searchText, userLatitude: cameraPosition.latitude,
              userLongitude: cameraPosition.longitude, maximumSearchDistance: 2000,
              isOpened: nil, hasCommunalTable: nil, filters: nil,
              pageSize: pageSize, pageableKey: PageableKey(lastCafeDistance: lastDistance)
            )
            let cafeSearchResponse = try await placeAPIClient.searchPlaces(requestValue: cafeRequest)
            return cafeSearchResponse
          }
          await send(.infiniteScrollSearchPlaceResponse(result))
        }

        // MARK: NaverMapView
      case .refreshButtonTapped:
        state.cameraUpdateReason = .changedByDeveloper
        return .send(.updateCafeMarkers)

      case .bottomFloatingButtonTapped(let buttonType):
        switch buttonType {
        case .currentLocationButton:
          state.isMovingToCurrentPosition = true
          return .send(.updateCurrentLocation)
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
        state.isSelectedCafe = true
        return .none

      case .mapViewTapped:
        state.selectedCafe = nil
        state.isSelectedCafe = false
        return .none

      case .movedToCurrentPosition:
        state.isMovingToCurrentPosition = false
        return .none

      case .markersUpdated:
        state.isUpdatingMarkers = false
        return .none

      case .cleardMarkers:
        state.shouldClearMarkers = false
        return .none

      case .bookmarkStateUpdated:
        state.isUpdatingBookmarkState = false
        return .none

      case .updateCameraUpdateReason(let updateReason):
        state.isMovingCameraPosition = true
        state.cameraUpdateReason = updateReason
        return .none

      case .cameraPositionMoved:
        state.isMovingCameraPosition = false
        return .none

      case .requestSearchPlaceResponse(let result, let title):
        switch result {
        case .success(let searchResponse):
          if searchResponse.cafes.isEmpty {
            return .send(.resetResult(.searchResultIsEmpty))
          }
          state.cafeList = searchResponse.cafes
          state.cafeMarkerList = searchResponse.cafes
          state.isUpdatingMarkers = true
          state.cafeSearchListState.cafeList = searchResponse.cafes
          state.cafeSearchListState.hasNext = searchResponse.hasNext
          guard let cafe = searchResponse.cafes.first else { return .none }
          state.selectedCafe = cafe
          state.isSelectedCafe = true
          state.currentCameraPosition = CLLocationCoordinate2D(
            latitude: cafe.latitude,
            longitude: cafe.longitude
          )
          state.isMovingToCurrentPosition = true
          state.cafeSearchListState.title = title
          state.displayViewType = .searchResultView
          state.cafeSearchState.previousViewType = .searchResultView
          return .send(.cafeSearchAction(.dismiss))

        case .failure(let error):
          state.cafeSearchState.currentBodyType = .searchResultEmptyView
          debugPrint(error)
          return .none
        }

      case .infiniteScrollSearchPlaceResponse(let result):
        switch result {
        case .success(let cafeSearchResponse):
          state.cafeSearchListState.hasNext = cafeSearchResponse.hasNext
          let removedDuplicationCafes = cafeSearchResponse.cafes.filter {
            state.cafeSearchListState.cafeList.contains($0).isFalse
          }
          if removedDuplicationCafes.isNotEmpty {
            state.cafeSearchListState.cafeList += cafeSearchResponse.cafes
            state.cafeMarkerList += cafeSearchResponse.cafes
            state.isUpdatingMarkers = true
          }
          return .none
        case .failure(let error):
          debugPrint(error)
          return .none
        }

        // MARK: Common
      case .resetResult(let resetState):
        state.cafeList = []
        state.cafeMarkerList = []
        state.cafeSearchListState.cafeList = []
        state.cafeSearchListState.hasNext = nil
        state.cameraUpdateReason = .changedByDeveloper
        state.shouldClearMarkers = true
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

      case .updateCafeFilter(let information):
        state.cafeFilterInformation = information
        state.cafeSearchListState.cafeFilterInformation = information
        return .merge(
          EffectTask(value: .cafeFilterMenus(action: .updateCafeFilter(information: information))),
          EffectTask(value: .cafeSearchListAction(
            .cafeFilterMenus(action: .updateCafeFilter(information: information))
          ))
        )

      case .filterBottomSheetDismissed:
        return EffectTask(
          value: .cafeFilterMenus(action: .updateCafeFilter(information: state.cafeFilterInformation))
        )

      default:
        return .none
      }
    }
  }
}
