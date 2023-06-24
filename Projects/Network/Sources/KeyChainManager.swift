//
//  KeyChainManager.swift
//  Network
//
//  Created by 천수현 on 2023/06/16.
//  Copyright © 2023 com.cafe. All rights reserved.
//

import Foundation

protocol KeychainManagerInterface {
  func addItem(key: String, value: String) -> Bool
  func getItem(key: String) -> String?
  func updateItem(key: String, value: String) -> Bool
  func deleteItem(key: String) -> Bool
  func deleteUserToken() -> Result<Void, Error>
}

public final class KeychainManager: KeychainManagerInterface {

  public enum KeychainError: Error {
    case noData
  }

  public static let shared = KeychainManager()

  private init() {}

  @discardableResult
  public func addItem(key: String, value: String) -> Bool {
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

      debugPrint("addItem Error : \(key))")
      return false
    }()

    return result
  }

  @discardableResult
  public func getItem(key: String) -> String? {
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

    debugPrint("getItem Error : \(key)")
    return nil
  }

  @discardableResult
  public func updateItem(key: String, value: String) -> Bool {
    let prevQuery: [CFString: Any] = [
      kSecClass: kSecClassGenericPassword,
      kSecAttrAccount: key
    ]
    let updateQuery: [CFString: Any] = [
      kSecValueData: (value as AnyObject).data(using: String.Encoding.utf8.rawValue) as Any
    ]

    let result: Bool = {
      let status = SecItemUpdate(prevQuery as CFDictionary, updateQuery as CFDictionary)
      if status == errSecSuccess { return true }

      debugPrint("updateItem Error : \(key)")
      return false
    }()

    return result
  }

  @discardableResult
  public func deleteItem(key: String) -> Bool {
    let deleteQuery: [CFString: Any] = [
      kSecClass: kSecClassGenericPassword,
      kSecAttrAccount: key
    ]
    let status = SecItemDelete(deleteQuery as CFDictionary)
    if status == errSecSuccess { return true }

    debugPrint("deleteItem Error : \(key)")
    return false
  }

  @discardableResult
  public func deleteUserToken() -> Result<Void, Error> {
    let deleteQuery: [CFString: Any] = [
      kSecClass: kSecClassGenericPassword,
      kSecAttrAccount: "token"
    ]
    let status = SecItemDelete(deleteQuery as CFDictionary)
    let anonymousDeleteQuery: [CFString: Any] = [
      kSecClass: kSecClassGenericPassword,
      kSecAttrAccount: "anonymousToken"
    ]
    let anonymousStatus = SecItemDelete(anonymousDeleteQuery as CFDictionary)
    if status == errSecSuccess || anonymousStatus == errSecSuccess { return .success(()) }
    return .failure(KeychainError.noData)
  }
}
