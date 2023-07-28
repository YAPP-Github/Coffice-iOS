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
    textView.textColor = UIColor(CofficeAsset.Colors.grayScale9.swiftUIColor)
    textView.applyCoffice(font: .paragraph)
    return textView
  }()

  @Binding var text: String?

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
    @Binding private(set) var text: String?
    let maxTextLength: Int = 200
    let maxNumberOfLines: Int = 11

    init(_ text: Binding<String?>) {
      self._text = text
    }
  }
}

extension CafeReviewTextView.Coordinator: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    var updatedText = textView.text

    if textView.text.count > maxTextLength {
      updatedText = String(textView.text.prefix(maxTextLength))
    }

    textView.text = updatedText
    $text.wrappedValue = updatedText
  }

  func sizeOf(string: String, constrainedToWidth width: Double, font: UIFont) -> CGSize {
    return (string as NSString).boundingRect(
      with: CGSize(width: width, height: .greatestFiniteMagnitude),
      options: NSStringDrawingOptions.usesLineFragmentOrigin,
      attributes: [.font: font],
      context: nil
    ).size
  }

  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    guard let font = textView.font else { return false }

    let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
    var textWidth = textView.frame.inset(by: textView.textContainerInset).width
    textWidth -= 2.0 * textView.textContainer.lineFragmentPadding

    let boundingRect = sizeOf(string: newText, constrainedToWidth: Double(textWidth), font: font)
    let numberOfLines = Int(boundingRect.height / font.lineHeight)

    return numberOfLines <= maxNumberOfLines
  }
}
