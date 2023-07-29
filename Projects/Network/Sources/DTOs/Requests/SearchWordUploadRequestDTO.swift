//
//  SearchWordUploadRequestDTO.swift
//  Network
//
//  Created by sehooon on 2023/07/28.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation

public struct SearchWordUploadRequestDTO: Encodable {
  public let text: String?

  public init(text: String?) {
    self.text = text
  }
}
