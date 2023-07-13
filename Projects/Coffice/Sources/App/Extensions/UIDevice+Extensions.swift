//
//  UIDevice+Extensions.swift
//  coffice
//
//  Created by MinKyeongTae on 2023/07/14.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import UIKit

extension UIDevice {
  struct DeviceModel: Decodable {
    let identifier: String
    let model: String
    static var all: [DeviceModel] {
      Bundle.main.decode([DeviceModel].self, from: "DeviceModels.json") ?? []
    }
  }
  var modelName: String {
#if targetEnvironment(simulator)
    let identifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? ""
#else
    var systemInfo = utsname()
    uname(&systemInfo)
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    let identifier = machineMirror.children.reduce("") { identifier, element in
      guard let value = element.value as? Int8, value != 0
      else { return identifier }
      return identifier + String(UnicodeScalar(UInt8(value)))
    }
#endif
    return DeviceModel.all.first { $0.identifier == identifier }?.model ?? identifier
  }
}
