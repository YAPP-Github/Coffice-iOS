//
//  CafeSearchCore.swift
//  coffice
//
//  Created by sehooon on 2023/06/27.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import Network
import SwiftUI

struct CafeSearchListCore: ReducerProtocol {
  struct State: Equatable {
    // TODO: filterButtonState 구현
    let filterOrders = FilterType.allCases
    var filterSheetState = FilterSheetCore.State(filterType: .cafeDetailFilter)
    var cafeList: [Cafe] = []
    var pageSize: Int = 10
    var pageNumber: Int = 0
    var pagenationRange: Range<Int> {
      pageNumber * pageSize..<(pageNumber + 1) * pageSize - 1
    }
  }

  enum Action: Equatable {
    case onAppear
    case updateState(FilterSheetCore.State)
    case presentFilterSheetView(FilterSheetCore.State)
    case searchPlaceResponse(TaskResult<[Cafe]>)
    case filterButtonTapped(FilterType)
    case scrollAndLoadData(Int)
    case dismiss
    case popView
  }

  @Dependency(\.placeAPIClient) private var placeAPIClient

  var body: some ReducerProtocolOf<CafeSearchListCore> {
    Reduce { state, action in
      switch action {
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
        state.filterSheetState = bottomSheetState
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

      case .filterButtonTapped(let filterButton):
        switch filterButton {
        case .outlet:
          state.filterSheetState.filterType = .outlet
          return EffectTask(value: .presentFilterSheetView(state.filterSheetState))

        case .spaceSize:
          return .none

        default:
          return .none
        }

      default:
        return .none
      }
    }
  }
}

extension CafeSearchListCore {
  enum FilterType: CaseIterable {
    case detail
    case runningTime
    case outlet
    case spaceSize
    case personnel

    var title: String {
      switch self {
      case .detail: return "CofficeAsset.Asset.filterLine24px"
      case .runningTime: return "영업시간"
      case .outlet: return "콘센트"
      case .spaceSize: return "공간크기"
      case .personnel: return "단체석"
      }
    }

    var size: (width: CGFloat, height: CGFloat) {
      switch self {
      case .detail: return (width: 56, height: 36)
      case .runningTime: return (width: 91, height: 36)
      case .outlet: return (width: 79, height: 36)
      case .spaceSize: return (width: 91, height: 36)
      case .personnel: return (width: 69, height: 36)
      }
    }
  }
}
