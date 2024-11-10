//
//  FollowModel.swift
//  CHEEK
//
//  Created by 김태은 on 10/10/24.
//

import Foundation

struct FollowModel: Identifiable, Codable {
    let memberId: Int64?
    let profilePicture: String?
    var following: Bool
    let nickname: String?
    let information: String?
    var followerCnt: Int64
    
    var id : Int64 { memberId ?? 0 }
}
