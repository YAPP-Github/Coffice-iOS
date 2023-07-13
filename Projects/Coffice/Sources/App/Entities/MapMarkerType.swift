//
//  MapMarkerType.swift
//  coffice
//
//  Created by 천수현 on 2023/07/06.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation

struct MapMarkerType {
  enum MarkerBookmarkType {
    case bookmarked
    case nonBookmarked
  }

  enum MarkerSelectType {
    case selected
    case unSelected
  }

  var bookmarkType: MarkerBookmarkType = .nonBookmarked
  var selectType: MarkerSelectType = .unSelected

  var width: CGFloat {
    switch (bookmarkType, selectType) {
    case (.nonBookmarked, .unSelected):
      return 20
    case (.nonBookmarked, .selected):
      return 28
    case (.bookmarked, .unSelected):
      return 20
    case (.bookmarked, .selected):
      return 28
    }
  }

  var height: CGFloat {
    switch (bookmarkType, selectType) {
    case (.nonBookmarked, .unSelected):
      return 20
    case (.nonBookmarked, .selected):
      return 36
    case (.bookmarked, .unSelected):
      return 20
    case (.bookmarked, .selected):
      return 36
    }
  }

  var image: CofficeImages.Image {
    switch (bookmarkType, selectType) {
    case (.nonBookmarked, .unSelected):
      return CofficeAsset.Asset.unselected20px.image
    case (.nonBookmarked, .selected):
      return CofficeAsset.Asset.selected2836px.image
    case (.bookmarked, .unSelected):
      return CofficeAsset.Asset.bookmarkUnselected20px.image
    case (.bookmarked, .selected):
      return CofficeAsset.Asset.bookmarkSelected2836px.image
    }
  }

  init(bookmarkType: MarkerBookmarkType, selectType: MarkerSelectType) {
    self.bookmarkType = bookmarkType
    self.selectType = selectType
  }
}
