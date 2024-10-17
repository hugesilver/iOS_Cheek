//
//  ProfileModel.swift
//  CHEEK
//
//  Created by 김태은 on 6/8/24.
//

import Foundation

// 자신의 프로필
struct ProfileModel: Codable {
    let memberId: Int64
    let email: String
    let nickname: String
    let information: String
    let description: String?
    let profilePicture: String?
    let role: String
    let status: String
    let followerCnt: Int64
    let followingCnt: Int64
}

// 타유저의 프로필
struct UserProfileModel: Codable, Equatable {
    let memberId: Int64
    let nickname: String
    let information: String
    let description: String?
    let profilePicture: String?
    let role: String
    var followerCnt: Int64
    let followingCnt: Int64
    var following: Bool
}

// 카드에 쓰이는 프로필 모델
struct MemberProfileModel: Codable {
    let memberId: Int64
    let nickname: String
    let information: String
    let description: String?
    let profilePicture: String?
}

struct MemberDto: Codable, Equatable {
    let memberId: Int64
    let nickname: String
    let profilePicture: String?
}
