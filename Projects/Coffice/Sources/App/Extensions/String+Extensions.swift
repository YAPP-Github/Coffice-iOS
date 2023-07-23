//
//  String+Extensions.swift
//  coffice
//
//  Created by Min Min on 2023/06/18.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation
import SwiftUI

extension String {
  var isNotEmpty: Bool { !isEmpty }

  func changeMatchTextColor(matchText: String) -> AttributedString {
    var attributedString = AttributedString(stringLiteral: self)
    guard let range = attributedString.range(of: matchText) else { return attributedString }
    attributedString[range].foregroundColor = CofficeAsset.Colors.secondary1.swiftUIColor
    attributedString[range].font = .custom(CofficeFont.subtitleSemiBold.name, size: 16)
    return attributedString
  }

  func utcDate(format: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

    guard let utcDate = dateFormatter.date(from: self)
    else { return nil }

    return utcDate
  }
}
