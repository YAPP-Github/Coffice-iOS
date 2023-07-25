//
//  UINavigationController+Extensions.swift
//  coffice
//
//  Created by Min Min on 2023/07/25.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import UIKit

extension UINavigationController: UIGestureRecognizerDelegate {
  override public func viewDidLoad() {
    super.viewDidLoad()
    interactivePopGestureRecognizer?.delegate = self
  }

  public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return viewControllers.count > 1
  }
}
