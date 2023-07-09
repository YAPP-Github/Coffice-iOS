//
//  Fonts.swift
//  coffice
//
//  Created by 천수현 on 2023/06/25.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation
import SwiftUI

enum CofficeFont {
  /// Header & Title
  case header0
  case header1
  case header2
  case header3
  case subtitle1Medium
  case subtitleSemiBold

  /// Button
  case button
  case buttonSmall
  case buttonCTA

  /// Body
  case body1
  case body1Medium
  case body2
  case body2Medium
  case body2MediumSemiBold
  case body3
  case body3Medium
  case paragraph

  case topbarTitle
}

extension CofficeFont {
  public var name: String {
    switch self {
    case .header0:
      return CofficeFontFamily.Pretendard.bold.name
    case .header1:
      return CofficeFontFamily.Pretendard.bold.name
    case .header2:
      return CofficeFontFamily.Pretendard.bold.name
    case .header3:
      return CofficeFontFamily.Pretendard.bold.name
    case .subtitle1Medium:
      return CofficeFontFamily.Pretendard.medium.name
    case .subtitleSemiBold:
      return CofficeFontFamily.Pretendard.semiBold.name

    case .button:
      return CofficeFontFamily.Pretendard.bold.name
    case .buttonSmall:
      return CofficeFontFamily.Pretendard.bold.name
    case .buttonCTA:
      return CofficeFontFamily.Pretendard.bold.name

    case .body1:
      return CofficeFontFamily.Pretendard.regular.name
    case .body1Medium:
      return CofficeFontFamily.Pretendard.medium.name
    case .body2Medium:
      return CofficeFontFamily.Pretendard.medium.name
    case .body2MediumSemiBold:
      return CofficeFontFamily.Pretendard.medium.name
    case .body2:
      return CofficeFontFamily.Pretendard.regular.name
    case .body3Medium:
      return CofficeFontFamily.Pretendard.medium.name
    case .body3:
      return CofficeFontFamily.Pretendard.regular.name
    case .paragraph:
      return CofficeFontFamily.Pretendard.regular.name

    case .topbarTitle:
      return CofficeFontFamily.Pretendard.semiBold.name
    }
  }

  public var size: CGFloat {
    switch self {
    case .header0:
      return 26
    case .header1:
      return 20
    case .header2:
      return 18
    case .header3:
      return 16
    case .subtitle1Medium:
      return 16
    case .subtitleSemiBold:
      return 16

    case .button:
      return 14
    case .buttonSmall:
      return 12
    case .buttonCTA:
      return 16

    case .body1:
      return 14
    case .body1Medium:
      return 14
    case .body2Medium:
      return 12
    case .body2MediumSemiBold:
      return 12
    case .body2:
      return 12
    case .body3Medium:
      return 10
    case .body3:
      return 10
    case .paragraph:
      return 14

    case .topbarTitle:
      return 16

    }
  }

  public var lineHeight: CGFloat {
    switch self {
    case .header0:
      return 36
    case .header1:
      return 32
    case .header2:
      return 24
    case .header3:
      return 20
    case .subtitle1Medium:
      return 20
    case .subtitleSemiBold:
      return 20

    case .button:
      return 20
    case .buttonSmall:
      return 20
    case .buttonCTA:
      return 20

    case .body1:
      return 20
    case .body1Medium:
      return 20
    case .body2Medium:
      return 18
    case .body2MediumSemiBold:
      return 18
    case .body2:
      return 18
    case .body3Medium:
      return 14
    case .body3:
      return 14
    case .paragraph:
      return 24
    case .topbarTitle:
      return 20
    }
  }

  public var kerning: CGFloat {
    switch self {
    case .header0:
      return 0
    case .header1:
      return 0
    case .header2:
      return 0
    case .header3:
      return 0
    case .subtitle1Medium:
      return 0
    case .subtitleSemiBold:
      return 0

    case .button:
      return 0
    case .buttonSmall:
      return 0
    case .buttonCTA:
      return 0

    case .body1:
      return 0
    case .body1Medium:
      return 0
    case .body2Medium:
      return 0
    case .body2MediumSemiBold:
      return 0
    case .body2:
      return 0
    case .body3Medium:
      return 0
    case .body3:
      return 0
    case .paragraph:
      return 0
    case .topbarTitle:
      return 0
    }
  }
}

struct FontModifier: ViewModifier {
  var font: CofficeFont
  var fontOriginalLineHeight: CGFloat {
    return UIFont(name: font.name, size: font.size)?.lineHeight ?? 20
  }

  init(font: CofficeFont) {
    self.font = font
  }

  func body(content: Content) -> some View {
    content
      .font(.custom(font.name, size: font.size))
      .lineSpacing(font.lineHeight - fontOriginalLineHeight)
      .padding(.vertical, (font.lineHeight - fontOriginalLineHeight) / 2)
  }
}

struct FontWithoutLineSpacingViewModifier: ViewModifier {
  var font: CofficeFont

  init(font: CofficeFont) {
    self.font = font
  }

  func body(content: Content) -> some View {
    content
      .font(.custom(font.name, size: font.size))
  }
}

extension View {
  func applyCofficeFont(font: CofficeFont) -> some View {
    modifier(FontModifier(font: font))
  }

  func applyCofficeFontWithoutLineSpacing(font: CofficeFont) -> some View {
    modifier(FontWithoutLineSpacingViewModifier(font: font))
  }
}
