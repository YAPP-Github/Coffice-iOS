//
//  UIApplication+Extensions.swift
//  Cafe
//
//  Created by MinKyeongTae on 2023/05/26.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import UIKit

extension UIApplication {
  static var keyWindow: UIWindow? {
    shared.connectedScenes
      .filter { $0.activationState == .foregroundActive }
      .first(where: { $0 is UIWindowScene })
      .flatMap({ $0 as? UIWindowScene })?.windows
      .first(where: \.isKeyWindow)
  }
}
