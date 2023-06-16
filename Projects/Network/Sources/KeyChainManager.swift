//
//  KeyChainManager.swift
//  Network
//
//  Created by 천수현 on 2023/06/16.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import Foundation

protocol KeychainManagerInterface {
  func addItem(key: Any, value: Any) -> Bool
  func getItem(key: Any) -> Any?
  func updateItem(key: Any, value: Any) -> Bool
  func deleteItem(key: String) -> Bool
  func deleteUserToken() -> Result<Void, Error>
}

final class KeychainManager: KeychainManagerInterface {

  enum KeychainError: Error {
    case noData
  }

  static let shared = KeychainManager()

  private init() {}

  func addItem(key: Any, value: Any) -> Bool {
    let addQuery: [CFString: Any] = [
      kSecClass: kSecClassGenericPassword,
      kSecAttrAccount: key,
      kSecValueData: (value as AnyObject).data(using: String.Encoding.utf8.rawValue) as Any
    ]

    let result: Bool = {
      let status = SecItemAdd(addQuery as CFDictionary, nil)
      if status == errSecSuccess {
        return true
      } else if status == errSecDuplicateItem {
        return updateItem(key: key, value: value)
      }

      print("addItem Error : \(key))")
      return false
    }()

    return result
  }

  func getItem(key: Any) -> Any? {
    let getQuery: [CFString: Any] = [
      kSecClass: kSecClassGenericPassword,
      kSecAttrAccount: key,
      kSecReturnAttributes: true,
      kSecReturnData: true
    ]
    var item: CFTypeRef?
    let result = SecItemCopyMatching(getQuery as CFDictionary, &item)

    if result == errSecSuccess {
      if let existingItem = item as? [String: Any],
         let data = existingItem[kSecValueData as String] as? Data,
         let password = String(data: data, encoding: .utf8) {
        return password
      }
    }

    print("getItem Error : \(key)")
    return nil
  }

  func updateItem(key: Any, value: Any) -> Bool {
    let prevQuery: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                kSecAttrAccount: key]
    let updateQuery: [CFString: Any] = [
      kSecValueData: (value as AnyObject).data(using: String.Encoding.utf8.rawValue) as Any
    ]

    let result: Bool = {
      let status = SecItemUpdate(prevQuery as CFDictionary, updateQuery as CFDictionary)
      if status == errSecSuccess { return true }

      print("updateItem Error : \(key)")
      return false
    }()

    return result
  }

  func deleteItem(key: String) -> Bool {
    let deleteQuery: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                  kSecAttrAccount: key]
    let status = SecItemDelete(deleteQuery as CFDictionary)
    if status == errSecSuccess { return true }

    print("deleteItem Error : \(key)")
    return false
  }

  func deleteUserToken() -> Result<Void, Error> {
    let deleteQuery: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                  kSecAttrAccount: "token"]
    let status = SecItemDelete(deleteQuery as CFDictionary)
    let lookAroundDeleteQuery: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                            kSecAttrAccount: "lookAroundToken"]
    let lookAroundStatus = SecItemDelete(lookAroundDeleteQuery as CFDictionary)
    if status == errSecSuccess || lookAroundStatus == errSecSuccess { return .success(()) }
    return .failure(KeychainError.noData)
  }
}
