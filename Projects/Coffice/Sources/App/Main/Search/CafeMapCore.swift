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
  enum ViewType {
    case mainMapView
    case searhView
    case resultMapView
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

  struct State: Equatable {
    var selectedCafe: Cafe?
    var isSelectedCafe: Bool = false
    var displayViewType: ViewType = .mainMapView
    var cafeSearchState = CafeSearchViewCore.State()
    var cafeSearchListState = CafeSearchListCore.State()

    var region: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 37.4971, longitude: 127.0287)
    var currentCameraPosition: CLLocationCoordinate2D?
    var cafeMarkerList: [CafeMarkerData] = []
    var cafeList: [Cafe] = []
    let filterOrders = FilterOrder.allCases
    let floatingButtons = FloatingButton.allCases
    @BindingState var searchText = ""
  }

  enum Action: Equatable, BindableAction {
    case cafeSearchListAction(CafeSearchListCore.Action)
    case updateDisplayType(ViewType)
    case cafeSearchViewAction(CafeSearchViewCore.Action)
    case requestSearchPlaceResponse(TaskResult<[Cafe]>)

    case binding(BindingAction<State>)

    case cameraDidChange(CLLocationCoordinate2D)

    case floatingButtonTapped(FloatingButton)
    case updateCurrentLocation
    case updateCafeMarkers
    case cafeListResponse(TaskResult<[CafeMarkerData]>)

    case filterOrderMenuClicked(FilterOrder)
    case pushToSearchDetailForTest(cafeId: Int)
    case pushToSearchListForTest

    case requestLocationAuthorization

    case updateCameraPosition(CLLocationCoordinate2D)
    case fetchCafeList

    case bookmarkButtonTapped
    case showToast(Toast.State)
  }

  @Dependency(\.placeAPIClient) private var placeAPIClient
  @Dependency(\.locationManager) private var locationManager

  var body: some ReducerProtocolOf<Self> {
    BindingReducer()

    Scope(state: \.cafeSearchListState, action: /CafeMapCore.Action.cafeSearchListAction) {
      CafeSearchListCore()
    }

    Scope(state: \.cafeSearchState, action: /CafeMapCore.Action.cafeSearchViewAction) {
        CafeSearchViewCore()
    }

    Reduce { state, action in
      switch action {
      case .cafeSearchListAction(.dismiss):
        state.cafeList = []
        state.cafeMarkerList = []
        state.isSelectedCafe = false
        state.displayViewType = .mainMapView
        return .none

      case .requestSearchPlaceResponse(let result):
        switch result {
        case .success(let cafeList):
          if cafeList.isEmpty {
            state.cafeList = []
            state.cafeMarkerList = []
            state.isSelectedCafe = false
            state.selectedCafe = nil
            return .none
          }
          state.cafeList = cafeList
          state.selectedCafe = cafeList.first!
          state.isSelectedCafe = true
          state.cafeMarkerList = cafeList.map {
            CafeMarkerData(
              cafeName: $0.name,
              latitude: $0.latitude,
              longitude: $0.longitude
            )
          }
          state.displayViewType = .resultMapView
          return .send(.cafeSearchViewAction(.dismiss))

        case .failure(let error):
          state.cafeSearchState.currentBodyType = .searchResultEmptyView
          debugPrint(error)
          return .none
        }

      case .cafeSearchViewAction(.requestSearchPlace(let searchText)):
        let latitude = state.region.latitude
        let longitude = state.region.longitude
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
          await send(.requestSearchPlaceResponse(result))
        }

      case .updateDisplayType(let displayType):
        state.displayViewType = displayType
        return .none

      case .cameraDidChange(let location):
        state.region = location
        return .none

      case .floatingButtonTapped(let buttonType):
        switch buttonType {
        case .currentLocationButton:
          return .send(.updateCurrentLocation)
        case .refreshButton:
          return .send(.updateCafeMarkers)
        case .bookmarkButton:
          return .none
        }

      case .updateCurrentLocation:
        state.region = locationManager.fetchCurrentLocation()
        return .none

      case .updateCafeMarkers:
        return .run { send in
          let result = await TaskResult {
            let cafeRequest = SearchPlaceRequestValue(
              searchText: "스타벅스", userLatitude: 37.498768, userLongitude: 127.0277985,
              maximumSearchDistance: 1000, isOpened: nil, hasCommunalTable: nil,
              filters: nil, pageSize: 10, pageableKey: nil
            )

            let cafeListData = try await placeAPIClient.searchPlaces(requestValue: cafeRequest)
            return cafeListData.cafes.map {
              CafeMarkerData(
                cafeName: $0.name,
                latitude: $0.latitude,
                longitude: $0.longitude
              )
            }
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

      case .requestLocationAuthorization:
        locationManager.requestAuthorization()
        return .none

      case .filterOrderMenuClicked(let filterOrder):
        switch filterOrder {
        case .searchList:
          return EffectTask(value: .pushToSearchListForTest)
        case .searchDetail:
          return EffectTask(value: .pushToSearchDetailForTest(cafeId: 1))
        default:
          return .none
        }

      case .bookmarkButtonTapped:
        return EffectTask(value: .showToast(.mock))

      default:
        return .none
      }
    }
  }
}
