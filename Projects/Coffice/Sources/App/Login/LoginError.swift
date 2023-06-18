//
//  LoginError.swift
//  coffice
//
//  Created by 천수현 on 2023/06/17.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation

enum LoginError: Error {
  case emptyAccessToken
  case jsonEncodeFailed
}
