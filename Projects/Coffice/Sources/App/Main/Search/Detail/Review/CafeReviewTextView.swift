//
//  CafeReviewTextView.swift
//  coffice
//
//  Created by MinKyeongTae on 2023/07/01.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import SwiftUI

struct CafeReviewTextView: UIViewRepresentable {
  private let textView: UITextView = {
    let textView = UITextView()
    textView.textColor = UIColor(Color(asset: CofficeAsset.Colors.grayScale9))
    textView.font = .systemFont(ofSize: 14)
    return textView
  }()

  @Binding var text: String

  func makeUIView(context: Context) -> UITextView {
    textView.delegate = context.coordinator
    return textView
  }

  func updateUIView(_ uiView: UITextView, context: Context) {
    uiView.text = text
  }

  func makeCoordinator() -> Coordinator {
    Coordinator($text)
  }

  class Coordinator: NSObject {
    var text: Binding<String>

    init(_ text: Binding<String>) {
      self.text = text
    }
  }
}

extension CafeReviewTextView.Coordinator: UITextViewDelegate {
  var maxTextLength: Int { 200 }

  func textViewDidChange(_ textView: UITextView) {
    var updatedText = textView.text ?? ""

    if textView.text.count > maxTextLength {
      updatedText = String(textView.text.prefix(maxTextLength))
    }

    textView.text = updatedText
    text.wrappedValue = updatedText
  }
}
