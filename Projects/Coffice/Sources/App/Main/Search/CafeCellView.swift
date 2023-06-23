//
//  CafeCellView.swift
//  coffice
//
//  Created by sehooon on 2023/06/23.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import SwiftUI

struct DefaultCafeCell {
  var cafeTitle: String = "카페이름"
  var location: String = "서울 마포구"
  var isOpend: String = "영업중"
  var cafeSize: String = "대형"
  var outlet: String = "콘센트 넉넉"
  var cafeThumbnail: [String] = ["cafeimage", "few", "fd", "cve"]
}

struct CafeCellView: View {
  // TODO: ViewState 연동 필요
  @State var defaultCafe = DefaultCafeCell()
  @State var isBookMarkButtonTapped =  false
  var body: some View {
    VStack(alignment: .leading) {
      cafeThumbnailView
        .padding(.vertical)
      cafeTitleBar
      Text("\(defaultCafe.location)")
        .padding(.bottom, 5)
      cafeStatusBar
    }
  }
}

extension CafeCellView {
  var cafeThumbnailView: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack {
        ForEach(defaultCafe.cafeThumbnail, id: \.self) { _ in
          Image(uiImage: CofficeAsset.cafeImage.image)
          .resizable()
          .frame(width: 150, height: 150)
        }
      }
    }
  }

  var cafeTitleBar: some View {
    HStack {
      Text("\(defaultCafe.cafeTitle)")
        .font(.headline)
      Spacer()
      Button {
        isBookMarkButtonTapped.toggle()
      } label: {
        Image(systemName: isBookMarkButtonTapped ? "bookmark.fill" : "bookmark")
          .resizable()
          .scaledToFit()
          .frame(width: 25, height: 25)
      }
      .buttonStyle(.plain)
    }
  }

  var cafeStatusBar: some View {
    HStack {
      Text("\(defaultCafe.isOpend)")
        .modifier(CafeCellViewModifier(fontColor: .red))
      Text("\(defaultCafe.outlet)")
        .modifier(CafeCellViewModifier(fontColor: .red))
      Text("\(defaultCafe.cafeSize)")
        .modifier(CafeCellViewModifier(fontColor: .red))
    }
  }
}

struct CafeCell_Previews: PreviewProvider {
  static var previews: some View {
    CafeCellView()
  }
}
