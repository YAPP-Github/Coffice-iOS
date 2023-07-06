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
      return 24
    case (.nonBookmarked, .selected):
      return 36
    case (.bookmarked, .unSelected):
      return 36
    case (.bookmarked, .selected):
      return 48
    }
  }

  var height: CGFloat {
    switch (bookmarkType, selectType) {
    case (.nonBookmarked, .unSelected):
      return 24
    case (.nonBookmarked, .selected):
      return 47
    case (.bookmarked, .unSelected):
      return 36
    case (.bookmarked, .selected):
      return 52
    }
  }

  var image: CofficeImages.Image {
    switch (bookmarkType, selectType) {
    case (.nonBookmarked, .unSelected):
      return NaverMapView.storage.unselectedIconImage
    case (.nonBookmarked, .selected):
      return NaverMapView.storage.selectedIconImage
    case (.bookmarked, .unSelected):
      return NaverMapView.storage.bookmarkUnselectedIconImage
    case (.bookmarked, .selected):
      return NaverMapView.storage.bookmarkSelectedIconImage
    }
  }

  init(bookmarkType: MarkerBookmarkType, selectType: MarkerSelectType) {
    self.bookmarkType = bookmarkType
    self.selectType = selectType
  }
}
