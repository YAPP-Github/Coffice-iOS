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

struct CafeMapCore: Reducer {
  // MARK: - State
  struct State: Equatable {
    // MARK: CardViewUI
    var maxScreenWidth: CGFloat = .zero
    var fixedImageSize: CGFloat { max(maxScreenWidth - 56, 0) / 3 }
    var fixedCardTitleSize: CGFloat { max(maxScreenWidth - 48, 0) }
    var isFirstOnAppear: Bool = true
    @BindingState var shouldShowToast = false
    var toastType: ToastType = .toastByBookmark

    // MARK: ViewType
    var displayViewType: ViewType = .mainMapView

    // MARK: Sub-Core States
    @BindingState var searchText = ""
    @BindingState var serviceAreaPopupState: ServiceAreaPopup.State?
    var cafeSearchState = CafeSearchCore.State()
    var cafeSearchListState = CafeSearchListCore.State()
    var cafeFilterMenusState: CafeFilterMenus.State = .initialState

    // MARK: CafeFilter
    var cafeFilterInformation: CafeFilterInformation?

    // MARK: NaverMapView
    var naverMapState = NaverMapCore.State()
  }

  // MARK: - Action
  enum Action: Equatable, BindableAction {
    // MARK: ViewType
    case updateDisplayType(ViewType)
    case updateMaxScreenWidth(CGFloat)

    // MARK: Sub-Core Actions
    case cafeSearchAction(CafeSearchCore.Action)
    case cafeSearchListAction(CafeSearchListCore.Action)
    case serviceAreaPopupAction(ServiceAreaPopup.Action)

    // MARK: NaverMapView
    case naverMapAction(NaverMapCore.Action)
    case refreshButtonTapped

    // MARK: Search
    case searchPlacesWithRequestValueByDefault
    case searchPlacesWithRequestValue(SearchPlaceRequestValue)
    case infiniteScrollSearchPlaceResponse(TaskResult<CafeSearchResponse>)
    case searchPlacesWithRequestValueResponse(TaskResult<CafeSearchResponse>)

    // MARK: Temporary
    case pushToCafeDetailView(cafeId: Int)
    case pushToSearchListForTest

    // MARK: Common
    case binding(BindingAction<State>)
    case requestLocationAuthorization
    case resetCafes
    case cafeFilterMenusAction(CafeFilterMenus.Action)
    case cardViewTapped
    case showToastBySearch
    case presentServiceAreaPopup
    case presentToast

    // MARK: View LifeCycle
    case onAppear
    case onDisappear
    case onBoarding

    // MARK: Need to improve
    case resetCafesForSearchList(ResetState)
  }

  // MARK: - Dependencies
  @Dependency(\.placeAPIClient) private var placeAPIClient
  @Dependency(\.locationManager) private var locationManager
  @Dependency(\.bookmarkClient) private var bookmarkClient

  // MARK: - Body
  var body: some ReducerOf<Self> {
    BindingReducer()

    Scope(state: \.cafeFilterMenusState, action: /Action.cafeFilterMenusAction) {
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
        switch state.displayViewType {
        case .searchResultView:
          state.cafeSearchState.previousViewType = .searchResultView
        case .mainMapView:
          state.cafeSearchState.previousViewType = .mainMapView
        default:
          break
        }
        state.displayViewType = displayType
        return .none

      case .updateMaxScreenWidth(let width):
        state.maxScreenWidth = width
        return .none

        // MARK: SearchListAction
      case .cafeSearchListAction(.focusSelectedCafe(let selectedCafe)):
        let newCameraPosition = CLLocationCoordinate2D(
          latitude: selectedCafe.latitude,
          longitude: selectedCafe.longitude
        )
        return .concatenate(
          .send(.naverMapAction(.selectCafe(cafe: selectedCafe))),
          .send(.naverMapAction(.moveCameraTo(position: newCameraPosition, zoomLevel: nil)))
        )

        // MARK: CafeSearch Delegate
      case .cafeSearchListAction(.delegate(.callSearchPlacesByFilter)):
        let currentCameraPosition = state.naverMapState.currentCameraPosition
        let filterInformation = state.cafeSearchListState.cafeFilterInformation
        let requestValue = SearchPlaceRequestValue(
          searchText: "",
          userLatitude: currentCameraPosition.latitude,
          userLongitude: currentCameraPosition.longitude,
          maximumSearchDistance: 2000,
          isOpened: filterInformation.isOpened,
          openAroundTheClock: filterInformation.openAroundTheClock,
          hasCommunalTable: filterInformation.hasCommunalTable,
          filters: filterInformation.cafeSearchFilters,
          pageSize: 10,
          pageableKey: nil
        )
        return .send(.cafeSearchListAction(.searchPlacesByFilter(requestValue)))

      case .cafeSearchListAction(.delegate(.didFinishSearchPlacesByFilter(let cafeResponse))):
        return .concatenate(
          .send(.naverMapAction(.updatePinnedCafes(cafes: cafeResponse.cafes))),
          .send(.updateDisplayType(.searchResultView))
        )

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

      case .cafeSearchListAction(.searchListCellBookmarkUpdated(let cafe)):
        return .send(.naverMapAction(.searchListCellBookmarkUpdated(cafe: cafe)))

      case .cafeSearchListAction(.titleLabelTapped):
        return .send(.updateDisplayType(.searchView))

      case .cafeSearchListAction(.updateCafeFilter(let information)):
        state.cafeFilterInformation = information
        return .send(
          .cafeFilterMenusAction(
            .updateCafeFilter(information: information)
          )
        )

      case .cafeSearchListAction(.dismiss):
        return .send(.resetCafesForSearchList(.dismissSearchResultView))

      case .cafeSearchListAction(.scrollAndRequestSearchPlace(let lastDistance)):
        let pageSize = state.cafeSearchListState.pageSize
        let filterInformation = state.cafeFilterInformation
        return .run { [cameraPosition = state.naverMapState.currentCameraPosition] send in
          let result = await TaskResult {
            let cafeRequest = SearchPlaceRequestValue(
              searchText: "",
              userLatitude: cameraPosition.latitude,
              userLongitude: cameraPosition.longitude,
              maximumSearchDistance: 2000,
              isOpened: filterInformation?.isOpened,
              openAroundTheClock: filterInformation?.openAroundTheClock,
              hasCommunalTable: filterInformation?.hasCommunalTable,
              filters: filterInformation?.cafeSearchFilters,
              pageSize: pageSize,
              pageableKey: PageableKey(lastCafeDistance: lastDistance)
            )
            let cafeSearchResponse = try await placeAPIClient.searchPlaces(by: cafeRequest)
            return cafeSearchResponse
          }
          await send(.infiniteScrollSearchPlaceResponse(result))
        }

        // MARK: NaverMapAction
      case .naverMapAction(.delegate(.callSearchPlacesWithRequestValue)):
        let cameraPosition = state.naverMapState.currentCameraPosition
        let filterInformation = state.cafeFilterInformation
        let requestValue = SearchPlaceRequestValue(
          searchText: "",
          userLatitude: cameraPosition.latitude,
          userLongitude: cameraPosition.longitude,
          maximumSearchDistance: 500,
          isOpened: filterInformation?.isOpened,
          openAroundTheClock: filterInformation?.openAroundTheClock,
          hasCommunalTable: filterInformation?.hasCommunalTable,
          filters: filterInformation?.cafeSearchFilters,
          pageSize: 9999999,
          pageableKey: nil
        )
        return .send(.naverMapAction(.searchPlacesWithRequestValue(requestValue: requestValue)))

      case .naverMapAction(.showBookmarkedToast):
        state.toastType = .toastByBookmark
        return .send(.presentToast)

      case .naverMapAction(.delegate(.callUpdateBookmarkSearchListCell(let cafe))):
        return .send(.cafeSearchListAction(.updateBookmarkedSearchListCell(cafe: cafe)))

      // MARK: Search Delegate
      case .cafeSearchAction(.delegate(.callSearchWithRequestValueByText(let searchText))):
        let currentCameraPosition = state.naverMapState.currentCameraPosition
        let filterInformation = state.cafeFilterInformation
        let requestValue = SearchPlaceRequestValue(
          searchText: searchText,
          userLatitude: currentCameraPosition.latitude,
          userLongitude: currentCameraPosition.longitude,
          maximumSearchDistance: 800000, // TODO: 제한 없이 MAX로 받는 방법 서버와 논의 필요
          isOpened: filterInformation?.isOpened,
          openAroundTheClock: filterInformation?.openAroundTheClock,
          hasCommunalTable: filterInformation?.hasCommunalTable,
          filters: filterInformation?.cafeSearchFilters,
          pageSize: 10, // TODO: 제한 없이 MAX로 받는 방법 서버와 논의 필요
          pageableKey: nil
        )
        return .send(.cafeSearchAction(.searchPlacesWithRequestValue(requestValue: requestValue)))

      case .cafeSearchAction(.delegate(.searchWithRequestValueByWaypoint(let waypoint))):
        let filterInformation = state.cafeFilterInformation
        let requestValue = SearchPlaceRequestValue(
          searchText: "",
          userLatitude: waypoint.latitude,
          userLongitude: waypoint.longitude,
          maximumSearchDistance: 2000, // TODO: 제한 없이 MAX로 받는 방법 서버와 논의 필요
          isOpened: filterInformation?.isOpened,
          openAroundTheClock: filterInformation?.openAroundTheClock,
          hasCommunalTable: filterInformation?.hasCommunalTable,
          filters: filterInformation?.cafeSearchFilters,
          pageSize: 10, // TODO: 제한 없이 MAX로 받는 방법 서버와 논의 필요
          pageableKey: nil
        )
        return .run { send in
          let cafeResponse = try await placeAPIClient.searchPlaces(by: requestValue)
          await send(.cafeSearchListAction(
            .updateCafeSearchListState(
              title: waypoint.name,
              cafeList: cafeResponse.cafes,
              hasNext: cafeResponse.hasNext
            )
          ))
          await send(
            .naverMapAction(.updatePinnedCafes(cafes: cafeResponse.cafes))
          )
          await send(
            .naverMapAction(
              .moveCameraTo(position: .init(latitude: waypoint.latitude, longitude: waypoint.longitude),
                            zoomLevel: nil)
            )
          )
          await send(.updateDisplayType(.searchResultView))
          if cafeResponse.cafes.isEmpty { await send(.showToastBySearch) }
        }

      case .cafeSearchAction(.delegate(.focusSelectedPlace(let cafes))):
        guard let cafe = cafes.first
        else { return .none }

        let newCameraPosition = CLLocationCoordinate2D(
          latitude: cafe.latitude,
          longitude: cafe.longitude
        )
        state.displayViewType = .searchResultView
        return .run { send in
          await send(.naverMapAction(.updatePinnedCafes(cafes: cafes)))
          await send(.naverMapAction(.selectCafe(cafe: cafe)))
          await send(.naverMapAction(.moveCameraTo(position: newCameraPosition, zoomLevel: nil)))
          await send(.cafeSearchListAction(
            .updateCafeSearchListState(
              title: cafe.name,
              cafeList: cafes,
              hasNext: false
            )
          ))
        }

        // MARK: Search
      case .searchPlacesWithRequestValueByDefault:
        let filterInformation = state.cafeFilterInformation
        let requestValue = SearchPlaceRequestValue(
          searchText: "",
          userLatitude: 37.4971,
          userLongitude: 127.0287,
          maximumSearchDistance: 3000,
          isOpened: filterInformation?.isOpened,
          openAroundTheClock: filterInformation?.openAroundTheClock,
          hasCommunalTable: filterInformation?.hasCommunalTable,
          filters: filterInformation?.cafeSearchFilters,
          pageSize: 9999,
          pageableKey: nil
        )
        return .send(.searchPlacesWithRequestValue(requestValue))

      case .searchPlacesWithRequestValue(let requestValue):
        return .run { send in
          let result = await TaskResult { return try await placeAPIClient.searchPlaces(by: requestValue) }
          await send(.searchPlacesWithRequestValueResponse(result))
        }

      case .searchPlacesWithRequestValueResponse(let result):
        switch result {
        case .success(let searchResponse):
          return .run { send in
            await send(.naverMapAction(.updatePinnedCafes(cafes: searchResponse.cafes)))
          }
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
          }
          return .run { send in
            if removedDuplicationCafes.isNotEmpty {
              await send(.naverMapAction(.addCafes(cafes: cafeSearchResponse.cafes)))
            }
          }
        case .failure(let error):
          debugPrint(error)
          return .none
        }

        // MARK: Common
      case .showToastBySearch:
        state.toastType = .toastBySearch
        return .send(.presentToast)

      case .resetCafes:
        return .merge(
          .send(.naverMapAction(.removeAllMarkers))
        )

      case .resetCafesForSearchList(let resetState):
        switch resetState {
        case .searchResultIsEmpty:
          state.cafeSearchState.previousViewType = .mainMapView
          state.cafeSearchState.bodyType = .searchResultEmptyView
        case .dismissSearchResultView:
          state.displayViewType = .mainMapView
        }
        return .merge(
          .send(.naverMapAction(.removeAllMarkers)),
          .send(.cafeSearchListAction(
            .updateCafeSearchListState(
              title: "",
              cafeList: [],
              hasNext: false
            )
          ))
        )

      case .requestLocationAuthorization:
        locationManager.requestAuthorization()
        return .none

      case .cafeFilterMenusAction(.delegate(.updateCafeFilter(let information))):
        state.cafeFilterInformation = information
        return .merge(
          .send(.cafeSearchListAction(
            .cafeFilterMenus(action: .updateCafeFilter(information: information))
          )),
          .send(.searchPlacesWithRequestValue(SearchPlaceRequestValue(
            searchText: "",
            userLatitude: state.naverMapState.currentCameraPosition.latitude,
            userLongitude: state.naverMapState.currentCameraPosition.longitude,
            maximumSearchDistance: 2000,
            isOpened: information.isOpened,
            openAroundTheClock: information.openAroundTheClock,
            hasCommunalTable: information.hasCommunalTable,
            filters: information.cafeSearchFilters,
            pageSize: 30,
            pageableKey: nil)
          ))
        )
      case .cardViewTapped:
        guard let cafe = state.naverMapState.selectedCafe
        else { return .none }
        return .send(.pushToCafeDetailView(cafeId: cafe.placeId))

      // MARK: View LifeCycle
      case .onBoarding:
        guard UserDefaults.standard.bool(forKey: UserDefaultsKeyString.onBoardingWithCafeMapView.forKey)
        else { return .none }

        return .merge(
          .send(.requestLocationAuthorization),
          .send(.searchPlacesWithRequestValueByDefault),
          .run { send in
            try await Task.sleep(nanoseconds: 1_000_000_000)
            await send(.presentServiceAreaPopup)
          }
        )

      case .presentServiceAreaPopup:
        state.serviceAreaPopupState = .init()
        return .none

      case .presentToast:
        state.shouldShowToast = true
        return .none

      case .onAppear:
        // 맵뷰 최초 진입 시 한번,(강남역 주변 마커 표출)
        if state.isFirstOnAppear {
          state.isFirstOnAppear = false
          return .send(.searchPlacesWithRequestValueByDefault)
        }
        return .send(.naverMapAction(.updateSelectedCafeState))

      case .serviceAreaPopupAction(.confirmButtonTapped):
        state.serviceAreaPopupState = nil
        return .none

      default:
        return .none
      }
    }
    .ifLet(
      \.serviceAreaPopupState,
      action: /Action.serviceAreaPopupAction
    ) {
      ServiceAreaPopup()
    }
  }
}

extension CafeMapCore {
  enum ToastType {
    case toastByBookmark
    case toastBySearch

    var title: String {
      switch self {
      case .toastByBookmark: return "장소가 저장되었습니다."
      case .toastBySearch: return "이 근처의 검색결과가 없어요!"
      }
    }

    var image: CofficeImages? {
      switch self {
      case .toastByBookmark: return CofficeAsset.Asset.checkboxCircleFill18px
      case .toastBySearch: return nil
      }
    }
  }

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
    case openTimeButton
    case bookmarkButton
    case currentLocationButton

    var selectedImage: Image {
      switch self {
      case .openTimeButton:
        return CofficeAsset.Asset.clockFloatingSelected48px.swiftUIImage
      case .bookmarkButton:
        return CofficeAsset.Asset.bookmarkFloatingSelected48px.swiftUIImage
      case .currentLocationButton:
        return CofficeAsset.Asset.currentPositionFloating48px.swiftUIImage
      }
    }

    var unselectedImage: Image {
      switch self {
      case .openTimeButton:
        return CofficeAsset.Asset.clockFloatingUnselected48px.swiftUIImage
      case .bookmarkButton:
        return CofficeAsset.Asset.bookmarkFloatingUnselected48px.swiftUIImage
      case .currentLocationButton:
        return CofficeAsset.Asset.currentPositionFloating48px.swiftUIImage
      }
    }
  }
}
