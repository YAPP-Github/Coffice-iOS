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
  func textViewDidChange(_ textView: UITextView) {
    text.wrappedValue = textView.text
  }

  func textViewDidBeginEditing(_ textView: UITextView) {
    guard textView.textColor == UIColor(Color(asset: CofficeAsset.Colors.grayScale6))
    else { return }

    textView.text = nil
    textView.textColor = UIColor(Color(asset: CofficeAsset.Colors.grayScale9))
  }

  func textViewDidEndEditing(_ textView: UITextView) {
    guard textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    else { return }

    textView.text = """
                    혼자서 오기 좋았나요?
                    테이블, 의자는 편했나요?
                    카페에서 작업하며 느꼈던 점들을 공유해주세요!
                    """
    textView.textColor = UIColor(Color(asset: CofficeAsset.Colors.grayScale6))
  }
}
