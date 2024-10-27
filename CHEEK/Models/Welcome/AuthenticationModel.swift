//
//  AuthTokenModel.swift
//  CHEEK
//
//  Created by 김태은 on 6/5/24.
//

import Foundation

struct OAuthLoginResponseModel: Codable {
    let memberId: Int64
    let grantType: String
    let accessToken: String
    let accessTokenExpireTime: String
    let refreshToken: String
    let refreshTokenExpireTime: String
    let profileComplete: Bool
}

struct AccessTokenModel: Codable {
    let grantType: String
    let accessToken: String
    let accessTokenExpireTime: String
}
