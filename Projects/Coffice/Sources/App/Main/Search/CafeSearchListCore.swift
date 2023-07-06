//
//  CafeSearchListCore.swift
//  coffice
//
//  Created by sehooon on 2023/06/27.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import Network
import SwiftUI

struct CafeSearchListCore: ReducerProtocol {
  enum ViewType {
    case mapView
    case listView
  }

  struct State: Equatable {
    // TODO: filterButtonState 구현
    let filterOrders = CafeFilterType.allCases
    var filterSheetState = CafeFilterBottomSheet.State(filterType: .detail)
    var title: String = ""
    var viewType: ViewType = .mapView
    var cafeList: [Cafe] = []
    var pageSize: Int = 10
    var pageNumber: Int = 0
    var pagenationRange: Range<Int> {
      pageNumber * pageSize..<(pageNumber + 1) * pageSize - 1
    }
  }

  enum Action: Equatable {
    case updateViewType(ViewType)
    case onAppear
    case updateState(CafeFilterBottomSheet.State)
    case presentFilterSheetView(CafeFilterBottomSheet.State)
    case searchPlaceResponse(TaskResult<[Cafe]>)
    case filterButtonTapped(CafeFilterType)
    case scrollAndLoadData(Int)
    case backbuttonTapped
    case dismiss
    case popView
    case titleLabelTapped
  }

  @Dependency(\.placeAPIClient) private var placeAPIClient

  var body: some ReducerProtocolOf<CafeSearchListCore> {
    Reduce { state, action in
      switch action {
      case .titleLabelTapped:
        return .none

      case .dismiss:
        return .none

      case .backbuttonTapped:
        state.cafeList = []
        state.pageNumber = 0
        return .send(.dismiss)

      case .updateViewType(let viewType):
        state.viewType = viewType
        return .none

      case .onAppear:
        return .run { send in
          let result = await TaskResult {
            let requestValue = SearchPlaceRequestValue(
              searchText: "스타벅스",
              userLatitude: 37.498768,
              userLongitude: 127.0277985,
              maximumSearchDistance: 10000,
              isOpened: nil,
              hasCommunalTable: nil,
              filters: nil,
              pageSize: 10,
              pageableKey: nil
            )
            let response = try await placeAPIClient.searchPlaces(requestValue: requestValue)
            return response.cafes
          }
          await send(.searchPlaceResponse(result))
        }

      case .updateState(let bottomSheetState):
        // TODO: 필터 업데이트 이벤트 구현 필요
        return .none

        // TODO: 무한스크롤 추후 수정 예정
      case .scrollAndLoadData(let itemIndex):
        let currentPageNumber = itemIndex / state.pageSize
        if state.pagenationRange ~= itemIndex || currentPageNumber <= state.pageNumber {
          return .none
        } else {
          state.pageNumber += 1
          return .none
        }

      case .searchPlaceResponse(.success(let cafeList)):
        state.cafeList += cafeList
        return .none

      case .searchPlaceResponse(.failure(let error)):
        debugPrint(error)
        return .none

      case .filterButtonTapped(let filterType):
        return EffectTask(value: .presentFilterSheetView(.init(filterType: filterType)))

      default:
        return .none
      }
    }
  }
}
