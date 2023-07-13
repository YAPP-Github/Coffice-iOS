//
//  ContactEmailViewState.swift
//  coffice
//
//  Created by MinKyeongTae on 2023/07/14.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import SwiftUI

extension Bundle {
  func decode<T: Decodable>(
    _ type: T.Type,
    from file: String,
    dateDecodingStategy: JSONDecoder.DateDecodingStrategy = .deferredToDate,
    keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys
  ) -> T {
    guard let url = CofficeResources.bundle.url(forResource: "DeviceModels", withExtension: "json")
    else {
      fatalError("Error: Failed to locate \(file) in bundle.")
    }
    guard let data = try? Data(contentsOf: url)
    else {
      fatalError("Error: Failed to load \(file) from bundle.")
    }

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = dateDecodingStategy
    decoder.keyDecodingStrategy = keyDecodingStrategy

    guard let loaded = try? decoder.decode(T.self, from: data)
    else {
      fatalError("Error: Failed to decode \(file) from bundle.")
    }
    return loaded
  }
}

extension UIDevice {
  struct DeviceModel: Decodable {
    let identifier: String
    let model: String
    static var all: [DeviceModel] {
      Bundle.main.decode([DeviceModel].self, from: "DeviceModels.json")
    }
  }
  var modelName: String {
#if targetEnvironment(simulator)
    let identifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"]!
#else
    var systemInfo = utsname()
    uname(&systemInfo)
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    let identifier = machineMirror.children.reduce("") { identifier, element in
      guard let value = element.value as? Int8, value != 0 else { return identifier }
      return identifier + String(UnicodeScalar(UInt8(value)))
    }
#endif
    return DeviceModel.all.first {$0.identifier == identifier }?.model ?? identifier
  }
}

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
