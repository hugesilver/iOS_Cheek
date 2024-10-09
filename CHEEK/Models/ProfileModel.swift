//
//  ProfileModel.swift
//  CHEEK
//
//  Created by 김태은 on 6/8/24.
//

import Foundation

struct UserProfileModel: Codable {
    var memberId: Int64
    var email: String
    var nickname: String
    var description: String?
    var information: String
    var profilePicture: String?
    var role: String
    var status: String
}

struct MemberProfileModel: Codable {
    var memberId: Int64
    var email: String
    var nickname: String
    var description: String?
    var information: String
    var profilePicture: String?
}
