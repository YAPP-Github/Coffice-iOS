//
//  Bundle+Extensions.swift
//  coffice
//
//  Created by MinKyeongTae on 2023/07/14.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation

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
