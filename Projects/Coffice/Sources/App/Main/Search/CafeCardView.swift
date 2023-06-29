//
//  CafeCardView.swift
//  coffice
//
//  Created by sehooon on 2023/06/26.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import SwiftUI

struct CafeCardView: View {
  var body: some View {
    RoundedRectangle(cornerRadius: 15)
      .foregroundColor(.white)
      .shadow(color: .gray, radius: 2, x: 0, y: 2)
      .overlay {
        HStack(spacing: 10) {
          Image(asset: CofficeAsset.Asset.cafeImage)
            .resizable()
            .frame(width: 100, height: 180)
            .cornerRadius(15, corners: [.topLeft, .bottomLeft])
            .scaledToFill()

          VStack(alignment: .leading, spacing: 10) {
            Spacer()

            HStack {
              Text("학림다방")
                .font(.headline)
              Spacer()
              Button {
              } label: {
                Image(systemName: "bookmark")
                  .foregroundColor(.gray)
              }
              .padding(.trailing)
            }

            HStack(spacing: 3) {
              Image(asset: CofficeAsset.Asset.mapPinFill18px)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
              Text("서울 용산")
                .font(.subheadline)
            }

            HStack {
              Text("영업시간")
                .font(.caption)
                .padding(EdgeInsets(top: 3, leading: 7, bottom: 3, trailing: 7))
                .overlay {
                  RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.orange, lineWidth: 1)
                }
                .foregroundColor(.orange)
              Text("08:00 ~ 21:00")
                .font(.caption)
            }

            HStack {
              Text("콘센트")
                .font(.caption)
                .padding(EdgeInsets(top: 3, leading: 7, bottom: 3, trailing: 7))
                .overlay {
                  RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.orange, lineWidth: 1)
                }
                .foregroundColor(.orange)
              Text("넉넉")
                .font(.caption)
              Spacer()
                .frame(width: 20)
              Text("카페크기")
                .font(.caption)
                .padding(EdgeInsets(top: 3, leading: 7, bottom: 3, trailing: 7))
                .overlay {
                  RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.orange, lineWidth: 1)
                }
                .foregroundColor(.orange)
              Text("대형")
                .font(.caption)
            }

            HStack {
              Text("단체석")
                .font(.caption)
                .padding(EdgeInsets(top: 3, leading: 7, bottom: 3, trailing: 7))
                .overlay {
                  RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.red, lineWidth: 1)
                }
                .foregroundColor(.red)
              Text("디저트")
                .font(.caption)
                .padding(EdgeInsets(top: 3, leading: 7, bottom: 3, trailing: 7))
                .overlay {
                  RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.red, lineWidth: 1)
                }
                .foregroundColor(.red)
            }
            Spacer()
          }
        }
      }
  }
}

struct CafeCardView_Previews: PreviewProvider {
  static var previews: some View {
    CafeCardView()
  }
}
