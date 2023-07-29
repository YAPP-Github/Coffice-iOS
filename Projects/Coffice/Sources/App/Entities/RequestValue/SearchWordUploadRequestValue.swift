//
//  SearchWordUploadRequestValue.swift
//  coffice
//
//  Created by sehooon on 2023/07/28.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation
import Network

struct SearchWordUploadRequestValue {
  let text: String?
}

extension SearchWordUploadRequestValue {
  func toDTO() -> SearchWordUploadRequestDTO {
    .init(text: text)
  }
}
