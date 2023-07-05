//
//  KeyboardPresentationReadable.swift
//  coffice
//
//  Created by MinKyeongTae on 2023/07/02.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Combine
import UIKit

protocol KeyboardPresentationReadable {
  var keyboardEventPublisher: AnyPublisher<Bool, Never> { get }
}

extension KeyboardPresentationReadable {
  var keyboardEventPublisher: AnyPublisher<Bool, Never> {
    Publishers.Merge(
      NotificationCenter.default
        .publisher(for: UIResponder.keyboardWillShowNotification)
        .map { _ in return true },
      NotificationCenter.default
        .publisher(for: UIResponder.keyboardWillHideNotification)
        .map { _ in return false }
    )
    .eraseToAnyPublisher()
  }
}
