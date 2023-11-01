//
//  SearchScreenCore.swift
//  Cafe
//
//  Created by MinKyeongTae on 2023/05/29.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture
import TCACoordinators

struct SearchScreen: Reducer {
  enum State: Equatable {
    /// 메인 페이지
    case cafeMap(CafeMapCore.State)
    case cafeSearchDetail(CafeDetail.State)
    case cafeSearchList(CafeSearchListCore.State)
    case cafeReviewWrite(CafeReviewWrite.State)
    case cafeReport(CafeReport.State)
  }

  enum Action: Equatable {
    case cafeMap(CafeMapCore.Action)
    case cafeSearchDetail(CafeDetail.Action)
    case cafeSearchList(CafeSearchListCore.Action)
    case cafeReviewWrite(CafeReviewWrite.Action)
    case cafeReport(CafeReport.Action)
    case popView
  }

  var body: some ReducerOf<SearchScreen> {
    Scope(
      state: /State.cafeMap,
      action: /Action.cafeMap
    ) {
      CafeMapCore()
    }

    Scope(
      state: /State.cafeSearchDetail,
      action: /Action.cafeSearchDetail
    ) {
      CafeDetail()
    }

    Scope(
      state: /State.cafeSearchList,
      action: /Action.cafeSearchList
    ) {
      CafeSearchListCore()
    }

    Scope(
      state: /State.cafeReviewWrite,
      action: /Action.cafeReviewWrite
    ) {
      CafeReviewWrite()
    }

    Scope(
      state: /State.cafeReport,
      action: /Action.cafeReport
    ) {
      CafeReport()
    }
  }
}
