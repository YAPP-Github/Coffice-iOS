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
    var data: [SearchPlaceResponseDTO] = []
    var pageSize: Int = 10
    var pageNumber: Int = -1
    var pagenationRange: Range<Int> {
      pageNumber * pageSize..<(pageNumber + 1) * pageSize - 1
    }
  }

  enum Action: Equatable {
    case updateState(FilterSheetCore.State)
    case presentFilterSheetView(FilterSheetCore.State)
    case fetchData(SearchPlaceRequestValue)
    case dataResponse(TaskResult<[SearchPlaceResponseDTO]>)
    case filterButtonTapped(FilterType)
    case scrollAndloadData(Int)
    case dismiss
    case popView
  }

  @Dependency(\.placeAPIClient) private var placeAPIClient

  var body: some ReducerProtocolOf<CafeSearchListCore> {
    Reduce { state, action in
      switch action {
      case .updateState(let bottomSheetState):
        state.filterSheetState = bottomSheetState
        return .none

      // TODO: 무한스크롤 추후 수정 예정
      case .scrollAndloadData(let itemIndex):
        let currentPageNumber = itemIndex/state.pageSize
        if state.pagenationRange ~= itemIndex || currentPageNumber <= state.pageNumber {
          return .none
        } else {
          state.pageNumber += 1
          return .send(
            .fetchData(
              SearchPlaceRequestValue(
                searchText: "스타", latitude: 37.4982763, longitude: 127.0268507, distacne: 13000000000,
                isOpened: nil, hasCommunalTable: nil, capcityLevel: nil, drinkType: nil, foodType: nil,
                pageSize: state.pageSize, pageNumber: state.pageNumber)
            )
          )
        }

      case .fetchData(let requestValue):
        return .run { send in
          let result = await TaskResult {
            let data = try await placeAPIClient.searchPlaces(requestValue: requestValue)
            return data
          }
          await send(.dataResponse(result))
        }

      case .dataResponse(.success(let data)):
        state.data += data
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
