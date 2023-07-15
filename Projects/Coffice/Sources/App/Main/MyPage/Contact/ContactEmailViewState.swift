//
//  ContactEmailViewState.swift
//  coffice
//
//  Created by MinKyeongTae on 2023/07/14.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import SwiftUI

struct ContactEmailViewState: Equatable, Identifiable {
  let id = UUID()
  let toAddress: String
  let subject: String
  let messageHeader: String
  var data: Data?
  var body: String {
    """
    - Application Name : \(displayName)
    - iOS version : \(UIDevice.current.systemVersion)
    - device name : \(UIDevice.current.modelName)
    - App version : \(appVersion)
    - App build : \(appBuild)
    \(messageHeader)
    ================================
    """
  }

  func send(openURL: OpenURLAction) {
    let subjectDescription = subject.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
    let bodyDescription = body.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
    let urlString = "mailto:\(toAddress)?subject=\(subjectDescription)&body=\(bodyDescription)"
    guard let url = URL(string: urlString) else { return }

    openURL(url) { accepted in
      if accepted.isFalse {
        debugPrint(
          """
          This device does not support email
          \(body)
          """
        )
      }
    }
  }
}

extension ContactEmailViewState {
  var displayName: String {
    CofficeResources.bundle.object(forInfoDictionaryKey: "CFBundleName")
    as? String ?? "Could not determine the application name"
  }
  var appBuild: String {
    CofficeResources.bundle.object(forInfoDictionaryKey: "CFBundleVersion")
    as? String ?? "Could not determine the application build number"
  }
  var appVersion: String {
    CofficeResources.bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString")
    as? String ?? "Could not determine the application version"
  }
}
