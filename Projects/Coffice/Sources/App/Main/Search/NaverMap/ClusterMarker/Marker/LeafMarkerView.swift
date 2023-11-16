//
//  LeafMarkerView.swift
//  coffice
//
//  Created by 김현미 on 2023/11/16.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import UIKit

class LeafMarkerView: UIView {

  // 컨테이너 영역 뷰
  private let containerView = UIView()

  private let markerImageView = UIImageView()

  override init(frame: CGRect) {
    super.init(frame: frame)
    print("LeafMarkerView init")

    viewConfigure()
    constraintConfigure()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    print("LeafMarkerView layoutSubviews")
    constraintConfigure()
  }

  private func viewConfigure() {
    // 컨테이너 뷰
    containerView.backgroundColor = .clear
    self.addSubview(containerView)

    markerImageView.image = UIImage(systemName: "pencil.circle.fill")
    containerView.addSubview(markerImageView)
  }

  func constraintConfigure() {
    containerView.translatesAutoresizingMaskIntoConstraints = false
    containerView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    containerView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
    containerView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
    containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
  }
}
