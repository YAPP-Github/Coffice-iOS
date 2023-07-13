//
//  ReviewsResponseDTO.swift
//  Network
//
//  Created by Min Min on 2023/07/13.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import Foundation

public typealias ReviewsResponseDTO = [ReviewResponseDTO]

public struct ReviewResponseDTO: Decodable {
  public let reviewId: Int
  public let member: Member
  public let electricOutletLevel, wifiLevel, noiseLevel, content: String
  public let createdAt, updatedAt: String

  public struct Member: Decodable {
    public let memberId: Int
    public let name: String
    public let authProviders: [AuthProvider]
  }

  public struct AuthProvider: Decodable {
    public let authProviderType, authProviderUserId, authProviderStatus: String
  }
}
