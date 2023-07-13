//
//  SavedListScreenCore.swift
//  Cafe
//
//  Created by MinKyeongTae on 2023/05/29.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture
import TCACoordinators

struct SavedListScreen: ReducerProtocol {
  enum State: Equatable {
    /// 메인 페이지
    case savedList(SavedList.State)
    case cafeSearchDetail(CafeDetail.State)
  }

  enum Action: Equatable {
    case savedList(SavedList.Action)
    case cafeSearchDetail(CafeDetail.Action)
  }

  var body: some ReducerProtocolOf<SavedListScreen> {
    Scope(
      state: /State.savedList,
      action: /Action.savedList
    ) {
      SavedList()
    }

    Scope(
      state: /State.cafeSearchDetail,
      action: /Action.cafeSearchDetail
    ) {
      CafeDetail()
    }
  }
}
