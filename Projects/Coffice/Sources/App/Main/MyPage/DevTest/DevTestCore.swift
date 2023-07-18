//
//  DevTestCore.swift
//  Cafe
//
//  Created by Min Min on 2023/06/13.
//  Copyright (c) 2023 com.cafe. All rights reserved.
//

import ComposableArchitecture
import Foundation

struct DevTest: ReducerProtocol {
  struct State: Equatable, Identifiable {
    static let initialState: State = .init()
    let id = UUID()
    // ■ TCA에서 UI와 State 프로퍼티를 바인딩하는 여러가지 방법이 있습니다.
    // - reference(옛날 방식 코드도 있으니 가려가며 참고)
    // https://www.pointfree.co/blog/posts/63-the-composable-architecture-%EF%B8%8F-swiftui-bindings
    // 1) @BindingState를 사용하지 않는 방법 (textFieldWithoutBindingState 참고)
    // - 바인딩할 변수에 대한 Action을 수동으로 구현해서 사용해야 합니다.
    // 2) @BindingState를 사용하는 방법 (textFieldWithBindingState 참고)
    // 2-1) binding할 변수의 앞에 @BindingState를 추가합니다.
    // 2-2) Reducer Action이 BindableAction을 준수해야합니다.
    //   - BindableAction을 위해 binding case를 추가해주어야 합니다. 해당 Action을 통해 바인딩한 BindingState의 이벤트 변화를 알 수 있습니다.
    // 2-3) Reducer body 안에 BindingReducer()를 추가합니다.
    var textFieldStringWithoutBindingState = ""
    @BindingState var textFieldStringWithBindingState = ""
    // TODO: BottomSheet 공용 UI 컴포넌트 구성 필요
    @BindingState var cafeFilterBottomSheetState: CafeFilterBottomSheet.State?

    let title = "개발자 기능 테스트"
  }

  enum Action: Equatable, BindableAction {
    case onAppear
    case popView

    // MARK: TextField
    /// BindingState의 변화를 감지하는 action case
    case binding(BindingAction<State>)
    /// 바인딩한 String 타입 변수의 변화를 받는 action case
    case textFieldStringDidChange(String)
    case presentCafeFilterBottomSheetView

    // MARK: Cafe Filter Bottom Sheet
    case cafeFilterBottomSheetAction(CafeFilterBottomSheet.Action)
  }

  var body: some ReducerProtocolOf<DevTest> {
    BindingReducer()

    Reduce { state, action in
      switch action {
      case .onAppear:
        return .none

      case .popView:
        return .none

      case .textFieldStringDidChange(let text):
        debugPrint("textFieldStringWithoutBindingState : \(text)")
        return .none

      case .presentCafeFilterBottomSheetView:
        state.cafeFilterBottomSheetState = .mock
        return .none

      default:
        return .none
      }
    }

    Reduce { state, action in
      switch action {
      case .binding(\.$textFieldStringWithBindingState):
        debugPrint("textFieldStringWithBindingState : \(state.textFieldStringWithBindingState)")
        return .none

      default:
        return .none
      }
    }

    // MARK: Cafe Filter Bottom Sheet
    Reduce { state, action in
      switch action {
      case .cafeFilterBottomSheetAction(let action):
        switch action {
        case .saveCafeFilter(let information):
          debugPrint("saved information : \(information)")
        case .dismiss:
          state.cafeFilterBottomSheetState = nil
        default:
          return .none
        }
        return .none

      default:
        return .none
      }
    }
    .ifLet(
      \.cafeFilterBottomSheetState,
      action: /Action.cafeFilterBottomSheetAction
    ) {
      CafeFilterBottomSheet()
    }
  }
}
