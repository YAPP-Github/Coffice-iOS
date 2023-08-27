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
    viewStore = ViewStore(store, observe: { $0 })
    webView = .init(frame: .zero)
    viewStore.send(.load(webView: webView))
  }

  func makeUIView(context: Context) -> WKWebView {
    webView
  }

  func updateUIView(_ uiView: WKWebView, context: Context) { }
}

struct CommonWebReducer: Reducer {
  struct State: Equatable, Identifiable {
    let id = UUID()
    let urlString: String
  }

  enum Action: Equatable {
    case load(webView: WKWebView)
  }

  var body: some ReducerOf<Self> {
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
