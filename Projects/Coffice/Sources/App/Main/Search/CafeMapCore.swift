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
  // MARK: - State
  struct State: Equatable {
    // MARK: CardViewUI
    var maxScreenWidth: CGFloat = .zero
    var fixedImageSize: CGFloat { (maxScreenWidth - 56) / 3 }
    var fixedCardTitleSize: CGFloat { maxScreenWidth - 48 }
    @BindingState var shouldShowToast = false
    // MARK: ViewType
    var displayViewType: ViewType = .mainMapView

    // MARK: Selecting Cafe
    var selectedCafe: Cafe?
    var isSelectedCafe: Bool = false

    // MARK: Search
    @BindingState var searchText = ""
    var cafeSearchState = CafeSearchCore.State()
    var cafeSearchListState: CafeSearchListCore.State = .init()
    var cafeFilterMenusState: CafeFilterMenus.State = .initialState

    // MARK: CafeFilter
    var cafeFilterInformation: CafeFilterInformation = .initialState

    // MARK: NaverMapView
    var currentCameraPosition = CLLocationCoordinate2D(latitude: 37.4971, longitude: 127.0287)
    var cafes: [Cafe] = []
    var shouldClearMarkers: Bool = false
    var bottomFloatingButtons = BottomFloatingButtonType.allCases.map(BottomFloatingButton.init)
    var isUpdatingCameraPosition = false
    var isUpdatingMarkers = false
    var shouldUpdateMarkers: Bool {
      return cafes.isNotEmpty && isUpdatingMarkers
    }
    var shouldShowBookmarkCafesOnly = false
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
    case bottomFloatingButtonTapped(BottomFloatingButtonType)
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
    case cameraPositionMoved(newCameraPosition: CLLocationCoordinate2D)

    // MARK: Search
    case infiniteScrollSearchPlaceResponse(TaskResult<CafeSearchResponse>)
    case requestSearchPlaceResponse(TaskResult<CafeSearchResponse>, String)
    case requestWaypointSearchPlaceResponse(TaskResult<CafeSearchResponse>)

    // MARK: Temporary
    case pushToSearchDetailForTest(cafeId: Int)
    case pushToSearchListForTest

    // MARK: Common
    case binding(BindingAction<State>)
    case requestLocationAuthorization
    case cardViewBookmarkButtonTapped(cafe: Cafe)
    case resetResult(ResetState)
    case cafeFilterMenus(action: CafeFilterMenus.Action)
    case updateCafeFilter(information: CafeFilterInformation)
    case filterBottomSheetDismissed
    case onDisappear
    case cardViewTapped
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
      case .cafeSearchAction(.searchPlacesByWaypoint(let waypoint)):
        state.cafeSearchListState.title = waypoint.name
        state.currentCameraPosition = CLLocationCoordinate2D(
          latitude: waypoint.latitude, longitude: waypoint.longitude
        )
        state.cafeSearchState.searchTextSnapshot = ""
        state.cafeSearchState.searchCameraPositionSnapshot = state.currentCameraPosition
        return .run { send in
          let result = await TaskResult {
            let cafeRequest = SearchPlaceRequestValue(
              searchText: "", userLatitude: waypoint.latitude, userLongitude: waypoint.longitude,
              maximumSearchDistance: 2000, isOpened: nil, hasCommunalTable: nil,
              filters: nil, pageSize: 10, pageableKey: nil
            )
            let cafeListData = try await placeAPIClient.searchPlaces(by: cafeRequest)
            return cafeListData
          }
          await send(.requestWaypointSearchPlaceResponse(result))
        }

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

      case .cafeSearchAction(.searchPlacesByRequestValue(let searchText)):
        let title = searchText
        let cameraPosition = state.currentCameraPosition
        let isOpened = state.cafeFilterInformation.isOpened
        let cafeSearchFilters = state.cafeFilterInformation.cafeSearchFilters
        let hasCommunalTable = state.cafeFilterInformation.hasCommunalTable
        state.cafeSearchState.searchTextSnapshot = searchText
        state.cafeSearchState.searchCameraPositionSnapshot = state.currentCameraPosition
        return .run { send in
          let result = await TaskResult {
            let cafeRequest = SearchPlaceRequestValue(
              searchText: searchText,
              userLatitude: cameraPosition.latitude,
              userLongitude: cameraPosition.longitude,
              maximumSearchDistance: 2000,
              isOpened: isOpened,
              hasCommunalTable: hasCommunalTable,
              filters: cafeSearchFilters,
              pageSize: 10,
              pageableKey: nil
            )
            let cafeSearchResponose = try await placeAPIClient.searchPlaces(by: cafeRequest)
            return cafeSearchResponose
          }
          await send(.requestSearchPlaceResponse(result, title))
        }

      case .cafeSearchListAction(.scrollAndRequestSearchPlace(let lastDistance)):
        guard let cameraPosition = state.cafeSearchState.searchCameraPositionSnapshot
        else { return .none }
        let pageSize = state.cafeSearchListState.pageSize
        let searchText = state.cafeSearchState.searchTextSnapshot
        let isOpened = state.cafeFilterInformation.isOpened
        let cafeSearchFilters = state.cafeFilterInformation.cafeSearchFilters
        let hasCommunalTable = state.cafeFilterInformation.hasCommunalTable
        return .run { send in
          let result = await TaskResult {
            let cafeRequest = SearchPlaceRequestValue(
              searchText: searchText,
              userLatitude: cameraPosition.latitude,
              userLongitude: cameraPosition.longitude,
              maximumSearchDistance: 2000,
              isOpened: isOpened,
              hasCommunalTable: hasCommunalTable,
              filters: cafeSearchFilters,
              pageSize: pageSize,
              pageableKey: PageableKey(lastCafeDistance: lastDistance)
            )
            let cafeSearchResponse = try await placeAPIClient.searchPlaces(by: cafeRequest)
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
          state.isUpdatingCameraPosition = true
          return .send(.updateCurrentLocation)
        case .bookmarkButton:
          if let bookmarkButtonIndex = state.bottomFloatingButtons
            .firstIndex(where: { $0.type == buttonType }) {
            state.isUpdatingMarkers = true
            state.bottomFloatingButtons[bookmarkButtonIndex].isSelected.toggle()
            state.shouldShowBookmarkCafesOnly = state.bottomFloatingButtons[bookmarkButtonIndex].isSelected
          }
          return .none
        }

      case .updateCurrentLocation:
        state.currentCameraPosition = locationManager.fetchCurrentLocation()
        return .none

      case .updateCafeMarkers:
        state.isUpdatingMarkers = true
        let isOpened = state.cafeFilterInformation.isOpened
        let cafeSearchFilters = state.cafeFilterInformation.cafeSearchFilters
        let hasCommunalTable = state.cafeFilterInformation.hasCommunalTable
        return .run { send in
          let result = await TaskResult {
            let cafeRequest = SearchPlaceRequestValue(
              searchText: "",
              userLatitude: 37.498768,
              userLongitude: 127.0277985,
              maximumSearchDistance: 500,
              isOpened: isOpened,
              hasCommunalTable: hasCommunalTable,
              filters: cafeSearchFilters,
              pageSize: 100000,
              pageableKey: nil
            )

            let cafeListData = try await placeAPIClient.searchPlaces(by: cafeRequest)
            return cafeListData.cafes
          }
          await send(.cafeListResponse(result))
        }

      case .cafeListResponse(let result):
        switch result {
        case .success(let cafeList):
          state.cafes = cafeList
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
        state.isUpdatingCameraPosition = false
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

      case .cameraPositionMoved(let newCameraPosition):
        state.currentCameraPosition = newCameraPosition
        state.isMovingCameraPosition = false
        return .none

      // MARK: Search
      case .requestSearchPlaceResponse(let result, let title):
        switch result {
        case .success(let searchResponse):
          if searchResponse.cafes.isEmpty {
            return .send(.resetResult(.searchResultIsEmpty))
          }
          state.cafes = searchResponse.cafes
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
          state.isUpdatingCameraPosition = true
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
            state.cafes += cafeSearchResponse.cafes
            state.isUpdatingMarkers = true
          }
          return .none
        case .failure(let error):
          debugPrint(error)
          return .none
        }

      case .requestWaypointSearchPlaceResponse(let result):
        switch result {
        case .success(let searchResponse):
          state.cafeSearchListState.hasNext = searchResponse.hasNext
          if searchResponse.cafes.isEmpty {
            return .send(.resetResult(.searchResultIsEmpty))
          }
          state.cafes = searchResponse.cafes
          state.selectedCafe = nil
          state.isUpdatingMarkers = true
          state.cafeSearchListState.cafeList = searchResponse.cafes
          state.cafeSearchListState.hasNext = searchResponse.hasNext
          state.isUpdatingCameraPosition = true
          state.displayViewType = .searchResultView
          state.cafeSearchState.previousViewType = .searchResultView
          return .send(.cafeSearchAction(.dismiss))
        case .failure(let error):
          debugPrint(error)
          return .none
        }

        // MARK: Common
      case .resetResult(let resetState):
        state.cafes = []
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

      case .cardViewBookmarkButtonTapped(let cafe):
        state.selectedCafe?.isBookmarked.toggle()
        if let selectedCafeIndex = state.cafes
          .firstIndex(where: { $0.placeId == state.selectedCafe?.placeId }) {
          state.cafes[selectedCafeIndex].isBookmarked.toggle()
        }
        state.isUpdatingBookmarkState = true
        if state.selectedCafe?.isBookmarked == true {
          state.shouldShowToast = true
        }
        return .run { [isBookmarked = state.selectedCafe?.isBookmarked] send in
          if isBookmarked == true {
            try await bookmarkClient.addMyPlace(placeId: cafe.placeId)
          } else {
            try await bookmarkClient.deleteMyPlace(placeId: cafe.placeId)
          }
        } catch: { error, send in
          debugPrint(error)
        }

      case .onDisappear:
        // TODO: MapView쪽 리셋 작업 필요
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

      case .cardViewTapped:
        guard let cafe = state.selectedCafe
        else { return .none }
        return EffectTask(value: .pushToSearchDetailForTest(cafeId: cafe.placeId))
      default:
        return .none
      }
    }
  }
}

extension CafeMapCore {
  enum ResetState {
    case searchResultIsEmpty
    case dismissSearchResultView
  }

  enum ViewType {
    case mainMapView
    case searchView
    case searchResultView
  }

  struct BottomFloatingButton: Hashable {
    var type: BottomFloatingButtonType
    var isSelected = false
    var image: Image {
      return isSelected ? type.selectedImage : type.unSelectedImage
    }

    init(type: BottomFloatingButtonType) {
      self.type = type
    }
  }

  enum BottomFloatingButtonType: CaseIterable {
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

    var selectedImage: Image {
      switch self {
      case .bookmarkButton:
        return CofficeAsset.Asset.bookmarkFloatingSelected48px.swiftUIImage
      case .currentLocationButton:
        return CofficeAsset.Asset.currentPositionFloating48px.swiftUIImage
      }
    }

    var unSelectedImage: Image {
      switch self {
      case .bookmarkButton:
        return CofficeAsset.Asset.bookmarkFloatingUnselected48px.swiftUIImage
      case .currentLocationButton:
        return CofficeAsset.Asset.currentPositionFloating48px.swiftUIImage
      }
    }
  }
}
