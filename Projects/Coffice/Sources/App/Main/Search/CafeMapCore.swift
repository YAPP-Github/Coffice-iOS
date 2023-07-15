//
//  CafeMapCore.swift
//  Cafe
//
//  Created by sehooon on 2023/06/01.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture
import NMapsMap
import SwiftUI

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

    // MARK: Search
    @BindingState var searchText = ""
    var cafeSearchState = CafeSearchCore.State()
    var cafeSearchListState: CafeSearchListCore.State = .init()
    var cafeFilterMenusState: CafeFilterMenus.State = .initialState

    // MARK: CafeFilter
    var cafeFilterInformation: CafeFilterInformation = .initialState

    // MARK: NaverMapView
    var naverMapState = NaverMapCore.State()
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
    case naverMapAction(NaverMapCore.Action)
    case updateCafeMarkers
    case refreshButtonTapped

    // MARK: Search
    case infiniteScrollSearchPlaceResponse(TaskResult<CafeSearchResponse>)
    case requestSearchPlaceResponse(TaskResult<CafeSearchResponse>, String)
    case requestWaypointSearchPlaceResponse(TaskResult<CafeSearchResponse>)
    case searchPlacesByFiltersResponse(TaskResult<CafeSearchResponse>)

    // MARK: Temporary
    case pushToSearchDetailForTest(cafeId: Int)
    case pushToSearchListForTest

    // MARK: Common
    case binding(BindingAction<State>)
    case requestLocationAuthorization
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

    Scope(state: \.naverMapState, action: /CafeMapCore.Action.naverMapAction) {
      NaverMapCore()
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
      case .cafeSearchListAction(.searchPlacesByFilter):
        if state.displayViewType == .mainMapView { return .none }
        let isOpened = state.cafeSearchListState.cafeFilterInformation.isOpened
        let cafeSearchFilters = state.cafeSearchListState.cafeFilterInformation.cafeSearchFilters
        let hasCommunalTable = state.cafeSearchListState.cafeFilterInformation.hasCommunalTable
        let searchText = state.cafeSearchState.searchTextSnapshot
        guard let cameraPosition = state.cafeSearchState.searchCameraPositionSnapshot
        else { return .none }
        return .run { send in
          let result = await TaskResult {
            let cafe = try await placeAPIClient.searchPlaces(by: SearchPlaceRequestValue(
              searchText: searchText, userLatitude: cameraPosition.latitude, userLongitude: cameraPosition.longitude,
              maximumSearchDistance: 2000, isOpened: isOpened,
              hasCommunalTable: hasCommunalTable, filters: cafeSearchFilters, pageSize: 10, pageableKey: nil)
            )
            return cafe
          }
          await send(.searchPlacesByFiltersResponse(result))
        }

      case .cafeSearchAction(.focusSelectedPlace(let cafe)):
        state.naverMapState.currentCameraPosition = CLLocationCoordinate2D(
          latitude: cafe.latitude, longitude: cafe.longitude)
        state.naverMapState.isUpdatingCameraPosition = true
        state.naverMapState.cafes = [cafe]
        state.naverMapState.selectedCafe = cafe
        state.naverMapState.isUpdatingMarkers = true
        state.displayViewType = .searchResultView
        return .merge(
          EffectTask(value: .cafeSearchListAction(
            .updateCafeSearchListState(
              title: cafe.name,
              cafeList: [cafe],
              hasNext: false
            )
          )),
          EffectTask(value: .cafeSearchAction(
            .updateCafeSearchState(text: cafe.name, cameraPosition: state.naverMapState.currentCameraPosition))
          )
        )

      case .cafeSearchListAction(.focusSelectedCafe(let selectedCafe)):
        state.naverMapState.currentCameraPosition = CLLocationCoordinate2D(
          latitude: selectedCafe.latitude, longitude: selectedCafe.longitude)
        state.naverMapState.isUpdatingCameraPosition = true
        state.naverMapState.selectedCafe = selectedCafe
        state.naverMapState.isUpdatingMarkers = true
        return .none

      case .cafeSearchAction(.searchPlacesByWaypoint(let waypoint)):
        state.cafeSearchListState.title = waypoint.name
        state.naverMapState.currentCameraPosition = CLLocationCoordinate2D(
          latitude: waypoint.latitude, longitude: waypoint.longitude
        )
        state.cafeSearchState.searchTextSnapshot = ""
        state.cafeSearchState.searchCameraPositionSnapshot = state.naverMapState.currentCameraPosition
        return .run { send in
          let result = await TaskResult {
            let cafeRequest = SearchPlaceRequestValue(
              searchText: "",
              userLatitude: waypoint.latitude,
              userLongitude: waypoint.longitude,
              maximumSearchDistance: 2000,
              isOpened: nil,
              hasCommunalTable: nil,
              filters: nil,
              pageSize: 10,
              pageableKey: nil
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
        let cameraPosition = state.naverMapState.currentCameraPosition
        let isOpened = state.cafeFilterInformation.isOpened
        let cafeSearchFilters = state.cafeFilterInformation.cafeSearchFilters
        let hasCommunalTable = state.cafeFilterInformation.hasCommunalTable
        state.cafeSearchState.searchTextSnapshot = searchText
        state.cafeSearchState.searchCameraPositionSnapshot = state.naverMapState.currentCameraPosition
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
      case .naverMapAction(.refreshButtonTapped):
        return EffectTask(value: .updateCafeMarkers)

      case .updateCafeMarkers:
        let isOpened = state.cafeFilterInformation.isOpened
        let cafeSearchFilters = state.cafeFilterInformation.cafeSearchFilters
        let hasCommunalTable = state.cafeFilterInformation.hasCommunalTable

        return EffectTask(value: .naverMapAction(
          .updateCafeMarkers(
            isOpened: isOpened,
            cafeSearchFilters: cafeSearchFilters,
            hasCommunalTable: hasCommunalTable
          )
        ))

        // MARK: Search
      case .searchPlacesByFiltersResponse(let result):
        switch result {
        case .success(let searchResponse):
          state.naverMapState.selectedCafe = nil
          state.naverMapState.shouldClearMarkers = true

          state.naverMapState.cafes = searchResponse.cafes
          state.naverMapState.isUpdatingMarkers = true

          return .send(.cafeSearchListAction(
            .updateCafeSearchListState(
              title: nil,
              cafeList: searchResponse.cafes,
              hasNext: searchResponse.hasNext)
          ))

        case .failure(let error):
          debugPrint(error)
          return .none
        }

      case .requestSearchPlaceResponse(let result, let title):
        switch result {
        case .success(let searchResponse):
          if searchResponse.cafes.isEmpty {
            return .send(.resetResult(.searchResultIsEmpty))
          }
          state.naverMapState.cafes = searchResponse.cafes
          state.naverMapState.isUpdatingMarkers = true
          state.cafeSearchListState.cafeList = searchResponse.cafes
          state.cafeSearchListState.hasNext = searchResponse.hasNext
          guard let cafe = searchResponse.cafes.first else { return .none }
          state.naverMapState.selectedCafe = cafe
          state.naverMapState.currentCameraPosition = CLLocationCoordinate2D(
            latitude: cafe.latitude,
            longitude: cafe.longitude
          )
          state.naverMapState.isUpdatingCameraPosition = true
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
            state.naverMapState.cafes += cafeSearchResponse.cafes
            state.naverMapState.isUpdatingMarkers = true
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
          state.naverMapState.cafes = searchResponse.cafes
          state.naverMapState.selectedCafe = nil
          state.naverMapState.isUpdatingMarkers = true
          state.cafeSearchListState.cafeList = searchResponse.cafes
          state.cafeSearchListState.hasNext = searchResponse.hasNext
          state.naverMapState.isUpdatingCameraPosition = true
          state.displayViewType = .searchResultView
          state.cafeSearchState.previousViewType = .searchResultView
          return .send(.cafeSearchAction(.dismiss))
        case .failure(let error):
          debugPrint(error)
          return .none
        }

        // MARK: Common
      case .resetResult(let resetState):
        state.naverMapState.cafes = []
        state.cafeSearchListState.cafeList = []
        state.cafeSearchListState.hasNext = nil
        state.naverMapState.cameraUpdateReason = .changedByDeveloper
        state.naverMapState.shouldClearMarkers = true
        state.naverMapState.selectedCafe = nil
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

      case .naverMapAction(.showBookmarkedToast):
        state.shouldShowToast = true
        return .none

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
        guard let cafe = state.naverMapState.selectedCafe
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
      return isSelected ? type.selectedImage : type.unselectedImage
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

    var unselectedImage: Image {
      switch self {
      case .bookmarkButton:
        return CofficeAsset.Asset.bookmarkFloatingUnselected48px.swiftUIImage
      case .currentLocationButton:
        return CofficeAsset.Asset.currentPositionFloating48px.swiftUIImage
      }
    }
  }
}
