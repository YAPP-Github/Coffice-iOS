//
//  CommonWebView.swift
//  coffice
//
//  Created by Min Min on 2023/07/16.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import ComposableArchitecture
import SwiftUI
import WebKit

struct CommonWebView: UIViewRepresentable {
  @ObservedObject private var viewStore: ViewStoreOf<CommonWebReducer>
  private let webView: WKWebView

  init(store: StoreOf<CommonWebReducer>) {
    viewStore = ViewStore(store)
    webView = .init(frame: .zero)
    viewStore.send(.load(webView: webView))
  }

  func makeUIView(context: Context) -> WKWebView {
    webView
  }

  func updateUIView(_ uiView: WKWebView, context: Context) { }
}

struct CommonWebReducer: ReducerProtocol {
  struct State: Equatable {
    let urlString: String
    var transitionType: TransitionType = .none
  }

  enum Action: Equatable {
    case load(webView: WKWebView)
  }

  var body: some ReducerProtocolOf<Self> {
    Reduce { state, action in
      switch action {
      case .load(let webView):
        guard let webUrl = URL(string: state.urlString)
        else { return .none }
        webView.load(URLRequest(url: webUrl))
        return .none
      }
    }
  }
}

extension CommonWebReducer {
  enum TransitionType: Equatable {
    case privacyPolicy
    case appServiceTerms
    case locationServiceTerms
    case none

    var title: String {
      switch self {
      case .privacyPolicy: return "개인정보 처리방침"
      case .locationServiceTerms: return "위치서비스 약관"
      case .appServiceTerms: return "서비스 이용약관"
      default: return ""
      }
    }

    var urlString: String {
      switch self {
      case .privacyPolicy:
        return "https://traveling-jade-4ad.notion.site/74a66cfd0dc34c17b0f2f8da4f1cd1bb"
      case .appServiceTerms:
        return "https://traveling-jade-4ad.notion.site/0b8d9c87d5be459c97860ddb4bffaa31"
      case .locationServiceTerms:
        return "https://traveling-jade-4ad.notion.site/f946b1a337704f108f11d3c6333569d8"
      default:
        return ""
      }
    }
  }
}
