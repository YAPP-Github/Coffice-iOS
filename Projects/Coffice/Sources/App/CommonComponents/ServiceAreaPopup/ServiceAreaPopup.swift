//
//  ServiceAreaPopup.swift
//  coffice
//
//  Created by sehooon on 2023/07/26.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture

struct ServiceAreaPopup: Reducer {
  struct State: Equatable {
    let title = "서비스 운영 지역"
    let description = """
                      현재 강남지역만 서비스 중이에요.
                      카페 등록 요청은 문의하기를 이용해 주세요!
                      """
  }

  enum Action: Equatable {
    case confirmButtonTapped
  }

  var body: some ReducerOf<ServiceAreaPopup> {
    Reduce { state, action in
      switch action {
      default:
        return .none
      }
    }
  }
}
