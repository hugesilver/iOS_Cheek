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
    var description: String
    var information: String
    var profilePicture: String
    var role: String
    var status: String
    
    init?(memberId: Int?, email: String?, nickname: String?, description: String?, information: String?, profilePicture: String?, role: String?, status: String?) {
        guard let memberId = memberId,
              let email = email,
              let nickname = nickname,
              let description = description,
              let information = information,
              let profilePicture = profilePicture,
              let role = role,
              let status = status
        else {
            print("ProfileModel init 실패")
            return nil
        }
        
        self.memberId = memberId
        self.email = email
        self.nickname = nickname
        self.description = description
        self.information = information
        self.profilePicture = profilePicture
        self.role = role
        self.status = status
    }
}
