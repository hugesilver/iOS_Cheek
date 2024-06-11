//
//  AuthTokenModel.swift
//  CHEEK
//
//  Created by 김태은 on 6/5/24.
//

import Foundation

struct AuthTokenModel: Codable {
    var accessToken: String
    var refreshToken: String
    var accessTokenExpireTime: String
    var refreshTokenExpireTime: String
    
    init?(accessToken: String?, refreshToken: String?, accessTokenExpireTime: String?, refreshTokenExpireTime: String?) {
        guard let accessToken = accessToken,
              let refreshToken = refreshToken,
              let accessTokenExpireTime = accessTokenExpireTime,
              let refreshTokenExpireTime = refreshTokenExpireTime 
        else {
            print("AuthTokenModel init 실패")
            return nil
        }
        
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.accessTokenExpireTime = accessTokenExpireTime
        self.refreshTokenExpireTime = refreshTokenExpireTime
    }
}
