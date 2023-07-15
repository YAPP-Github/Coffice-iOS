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

    // MARK: Sub-Core States
    @BindingState var searchText = ""
    var cafeSearchState = CafeSearchCore.State()
    var cafeSearchListState = CafeSearchListCore.State()
    var cafeFilterMenusState = CafeFilterMenus.State.initialState

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
    case searhPlacesWithRequestValue(requestValue: SearchPlaceRequestValue)
    case infiniteScrollSearchPlaceResponse(TaskResult<CafeSearchResponse>)
    case searchPlacesByRequestValueResponse(TaskResult<CafeSearchResponse>)

    // MARK: Temporary
    case pushToSearchDetailForTest(cafeId: Int)
    case pushToSearchListForTest

    // MARK: Common
    case binding(BindingAction<State>)
    case requestLocationAuthorization
    case resetCafes(ResetState)
    case cafeFilterMenusAction(CafeFilterMenus.Action)
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
      action: /Action.cafeFilterMenusAction
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

        // MARK: SearchListAction
      case .cafeSearchListAction(.searchPlacesByFilter):
        if state.displayViewType == .mainMapView { return .none }
        let isOpened = state.cafeSearchListState.cafeFilterInformation.isOpened
        let cafeSearchFilters = state.cafeSearchListState.cafeFilterInformation.cafeSearchFilters
        let hasCommunalTable = state.cafeSearchListState.cafeFilterInformation.hasCommunalTable
        let searchText = state.cafeSearchState.searchText

        let request = SearchPlaceRequestValue(
          searchText: searchText,
          userLatitude: state.naverMapState.currentCameraPosition.latitude,
          userLongitude: state.naverMapState.currentCameraPosition.longitude,
          maximumSearchDistance: 2000,
          isOpened: isOpened,
          hasCommunalTable: hasCommunalTable,
          filters: cafeSearchFilters,
          pageSize: 10,
          pageableKey: nil
        )

        return .none
//        return EffectTask(
//          value: .cafeSearchListAction(
//            .searchPlacesByFilter(requestValue: request)
//          )
//        )

      case .cafeSearchListAction(.focusSelectedCafe(let selectedCafe)):
        state.naverMapState.currentCameraPosition = CLLocationCoordinate2D(
          latitude: selectedCafe.latitude, longitude: selectedCafe.longitude)
        state.naverMapState.isUpdatingCameraPosition = true
        state.naverMapState.selectedCafe = selectedCafe
        state.naverMapState.isUpdatingMarkers = true
        return .none

        // MARK: CafeSearch Delegate
      case .cafeSearchAction(.delegate(.dismiss)):
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
        return .send(.resetCafes(.dismissSearchResultView))

      case .cafeSearchListAction(.scrollAndRequestSearchPlace(let lastDistance)):
        let pageSize = state.cafeSearchListState.pageSize
        let searchText = state.cafeSearchState.searchText
        let isOpened = state.cafeFilterInformation.isOpened
        let cafeSearchFilters = state.cafeFilterInformation.cafeSearchFilters
        let hasCommunalTable = state.cafeFilterInformation.hasCommunalTable
        return .run { [cameraPosition = state.naverMapState.currentCameraPosition] send in
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

        // MARK: NaverMapAction
      case .naverMapAction(.refreshButtonTapped):
        return EffectTask(value: .updateCafeMarkers)

      case .updateCafeMarkers:
        let isOpened = state.cafeFilterInformation.isOpened
        let cafeSearchFilters = state.cafeFilterInformation.cafeSearchFilters
        let hasCommunalTable = state.cafeFilterInformation.hasCommunalTable

        return EffectTask(
          value: .naverMapAction(
            .updateCafeMarkers(
              isOpened: isOpened,
              cafeSearchFilters: cafeSearchFilters,
              hasCommunalTable: hasCommunalTable
            )
          )
        )

      case .naverMapAction(.showBookmarkedToast):
        state.shouldShowToast = true
        return .none

      // MARK: Search Delegate

      case .cafeSearchAction(.delegate(.requestToCallSearchWithRequestValue(let searchText))):
        let currentCameraPosition = state.naverMapState.currentCameraPosition
        let filterInformation = state.cafeFilterInformation
        let requestValue = SearchPlaceRequestValue(
          searchText: searchText,
          userLatitude: currentCameraPosition.latitude,
          userLongitude: currentCameraPosition.longitude,
          maximumSearchDistance: 9999999, // TODO: 제한 없이 MAX로 받는 방법 서버와 논의 필요
          isOpened: filterInformation.isOpened,
          hasCommunalTable: filterInformation.hasCommunalTable,
          filters: filterInformation.cafeSearchFilters,
          pageSize: 9999999, // TODO: 제한 없이 MAX로 받는 방법 서버와 논의 필요
          pageableKey: nil
        )
        return EffectTask(value: .cafeSearchAction(.searchPlacesWithRequestValue(requestValue: requestValue)))

      case .cafeSearchAction(.delegate(.focusSelectedPlace(let cafe))):
        state.naverMapState.currentCameraPosition = CLLocationCoordinate2D(
          latitude: cafe.latitude,
          longitude: cafe.longitude
        )
        state.naverMapState.isUpdatingCameraPosition = true
        state.naverMapState.cafes = [cafe]
        state.naverMapState.selectedCafe = cafe
        state.naverMapState.isUpdatingMarkers = true
        state.displayViewType = .searchResultView
        return EffectTask(
          value: .cafeSearchListAction(
            .updateCafeSearchListState(
              title: cafe.name,
              cafeList: [cafe],
              hasNext: false
            )
          )
        )

        // MARK: Search

      case .searchPlacesByRequestValueResponse(let result):
        switch result {
        case .success(let searchResponse):
          state.naverMapState.selectedCafe = nil
          state.naverMapState.shouldClearMarkers = true

          state.naverMapState.cafes = searchResponse.cafes
          state.naverMapState.isUpdatingMarkers = true

          return .send(
            .cafeSearchListAction(
              .updateCafeSearchListState(
                title: nil,
                cafeList: searchResponse.cafes,
                hasNext: searchResponse.hasNext
              )
            )
          )

        case .failure(let error):
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

        // MARK: Common
      case .resetCafes(let resetState):
        state.naverMapState.cafes = []
        state.cafeSearchListState.cafeList = []
        state.cafeSearchListState.hasNext = nil
        state.naverMapState.cameraUpdateReason = .changedByDeveloper
        state.naverMapState.shouldClearMarkers = true
        state.naverMapState.selectedCafe = nil
        switch resetState {
        case .searchResultIsEmpty:
          state.cafeSearchState.previousViewType = .mainMapView
          state.cafeSearchState.bodyType = .searchResultEmptyView
          return .none
        case .dismissSearchResultView:
          state.displayViewType = .mainMapView
          return .none
        }

      case .requestLocationAuthorization:
        locationManager.requestAuthorization()
        return .none

      case .updateCafeFilter(let information):
        state.cafeFilterInformation = information
        state.cafeSearchListState.cafeFilterInformation = information
        return .merge(
          EffectTask(value: .cafeFilterMenusAction(.updateCafeFilter(information: information))),
          EffectTask(value: .cafeSearchListAction(
            .cafeFilterMenus(action: .updateCafeFilter(information: information))
          ))
        )

      case .filterBottomSheetDismissed:
        return EffectTask(
          value: .cafeFilterMenusAction(.updateCafeFilter(information: state.cafeFilterInformation))
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
