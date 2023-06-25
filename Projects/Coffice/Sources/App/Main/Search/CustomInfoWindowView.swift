//
//  MarkerCustomView.swift
//  coffice
//
//  Created by sehooon on 2023/06/25.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import UIKit
class CustomInfoWindowView: UIView {
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupView()
  }

  private func setupView() {
    backgroundColor = .red
  }
}
