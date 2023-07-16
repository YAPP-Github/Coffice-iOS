//
//  CheckNicknameResponse.swift
//  coffice
//
//  Created by 천수현 on 2023/07/16.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation
import Network

enum CheckNicknameResponse {
  case valid
  case duplicated
  case tooShort
  case tooLong
  case isEmpty
  case containsIllegalCharacters
  case unknownError

  var serverCode: String {
    switch self {
    case .valid:
      return "SUCCESS"
    case .duplicated:
      return "MEMBER_NAME_DUPLICATED"
    case .tooShort:
      return "MEMBER_NAME_LENGTH_TOO_SHORT"
    case .tooLong:
      return "MEMBER_NAME_LENGTH_TOO_LONG"
    case .isEmpty:
      return "MEMBER_NAME_EMPTY"
    case .containsIllegalCharacters:
      return "MEMBER_NAME_CONTAINS_ILLEGAL_CHARACTERS"
    case .unknownError:
      return "UNKNOWN_ERROR"
    }
  }

  var warningMessage: String {
    switch self {
    case .duplicated:
      return "이미 존재하는 닉네임입니다."
    case .tooLong, .tooShort:
      return "한글/영어/숫자 최소 2자, 최대 15자로 입력해주세요."
    default:
      return ""
    }
  }

  static func response(of networkResult: NetworkResult<MemberResponseDTO>) -> CheckNicknameResponse {
    switch networkResult.code {
    case "SUCCESS":
      return .valid
    case "MEMBER_NAME_DUPLICATED":
      return .duplicated
    case "MEMBER_NAME_LENGTH_TOO_SHORT":
      return .tooShort
    case "MEMBER_NAME_LENGTH_TOO_LONG":
      return .tooLong
    case "MEMBER_NAME_EMPTY":
      return .isEmpty
    case "MEMBER_NAME_CONTAINS_ILLEGAL_CHARACTERS":
      return .containsIllegalCharacters
    default:
      return .unknownError
    }
  }
}
