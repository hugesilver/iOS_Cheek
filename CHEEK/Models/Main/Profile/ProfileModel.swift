//
//  ProfileModel.swift
//  CHEEK
//
//  Created by 김태은 on 6/8/24.
//

import Foundation

// 프로필
struct ProfileModel: Identifiable, Codable, Equatable {
    let memberId: Int64
    let nickname: String
    let information: String
    let description: String?
    var role: String
    var following: Bool
    var followerCnt: Int64
    var followingCnt: Int64
    let profilePicture: String?
    
    var id: Int64 {
        memberId
    }
}

// 카드에 쓰이는 프로필 모델
struct MemberProfileModel: Codable {
    let memberId: Int64?
    let nickname: String?
    let information: String?
    let description: String?
    let profilePicture: String?
}

// 간략 프로필 정보 모델
struct MemberDto: Codable, Equatable {
    let memberId: Int64?
    let nickname: String?
    let profilePicture: String?
}
