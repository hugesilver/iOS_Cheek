//
//  AdminMemberInfoModel.swift
//  CHEEK
//
//  Created by 김태은 on 11/7/24.
//

import Foundation

struct AdminMemberInfoModel: Identifiable, Codable {
    let memberId: Int64
    let nickname: String
    let email: String
    var role: String
    
    var id: Int64 {
        memberId
    }
}
