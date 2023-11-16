//
//  ClusterdMarkerView.swift
//  coffice
//
//  Created by 김현미 on 2023/11/16.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import UIKit

class ClusteredMarkerView: UIView {

  // 컨테이너 영역 뷰
  private let containerView = UIView()
  private let countLbl = UILabel()
  // 지역 클러스터링 개수
  var count: Int = 0

  init(frame: CGRect, count: Int) {
    super.init(frame: frame)
    //        Log.debug("ClusteredMarkerView init")
    self.count = count
    viewConfigure()
    constraintConfigure()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    //        Log.debug("ClusteredMarkerView layoutSubviews")
    constraintConfigure()
  }

  private func viewConfigure() {

    // 컨테이너 뷰
    containerView.layer.borderWidth = 1
    //        containerView.layer.borderColor = UIColor.green.cgColor
    containerView.layer.cornerRadius = bounds.size.height / 2
    //        containerView.backgroundColor = .clear
    self.addSubview(containerView)
    // 지역 지점 버튼
    self.countLbl.text = ("\(self.count) 개")
    countLbl.font = UIFont.systemFont(ofSize: 14, weight: .bold)
    //        countLbl.textColor = .black
    containerView.addSubview(countLbl)

    if count > 200 {
      containerView.backgroundColor = UIColor(red: 10/255, green: 77/255, blue: 104/255, alpha: 0.8)
      countLbl.textColor = .white
    } else if count > 100 {
      containerView.backgroundColor = UIColor(red: 139/255, green: 24/255, blue: 16/255, alpha: 0.8)
      countLbl.textColor = .white
    } else if count > 50 {
      containerView.backgroundColor = UIColor(red: 183/255, green: 19/255, blue: 117/255, alpha: 0.8)
      countLbl.textColor = .white
    } else if count > 10 {
      containerView.backgroundColor = UIColor(red: 247/255, green: 149/255, blue: 64/255, alpha: 0.8)
      countLbl.textColor = .black
    } else {
      containerView.backgroundColor = UIColor(red: 255/255, green: 234/255, blue: 210/255, alpha: 0.8)
      countLbl.textColor = .black
    }


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
