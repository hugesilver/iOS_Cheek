//
//  ProfileModel.swift
//  CHEEK
//
//  Created by 김태은 on 6/8/24.
//

import Foundation

struct ProfileModel: Codable {
    var memberId: Int
    var email: String
    var nickname: String
    var description: String?
    var information: String
    var profilePicture: String?
    var role: String
    var status: String
}
