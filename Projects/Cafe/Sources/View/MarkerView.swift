//
//  MarkerView.swift
//
//  Created by sehooon on 2023/05/31.
//

import SwiftUI

struct MarkerView: View {
  var cafeName: String = "학림 다방"
  var subTitle: String = "서울특별시 종로구 대학로 119"
  var description: String = ""

    var body: some View {
      VStack {
        VStack(alignment: .leading) {
          Text(cafeName)
            .font(.headline)
          Text(subTitle)
            .font(.subheadline)
            .foregroundColor(.gray)
          Divider()
          Text(description)
          Text("평점: 5.0, 공부하기 좋은 카페")
        }
        .padding(.top, 10)
        .padding(.bottom, 17)
        .padding(.horizontal, 17)
        .background(AddressBubble())
        .padding(.bottom, 3)

        Image("coffee")
          .resizable()
          .scaledToFit()
          .frame(width: 20)
      }
    }
}

struct AddressBubble: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(lineWidth: 1)
                    .background(Color.white)
                    .cornerRadius(12)

                Spacer()
            }
            Triangle()
                .stroke(lineWidth: 1)
                .frame(width: 12, height: 8)
                .background(Color.white)
                .clipShape(Triangle())

            Rectangle()
                .frame(width: 10.5, height: 2)
                .foregroundColor(.white)
                .padding(.bottom, 7.5)
        }
    }

    struct Triangle: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            return path
        }
    }
}

struct MarkerView_Previews: PreviewProvider {
    static var previews: some View {
        MarkerView()
    }
}
