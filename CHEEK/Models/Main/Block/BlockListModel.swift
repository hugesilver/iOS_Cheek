//
//  BlockListModel.swift
//  CHEEK
//
//  Created by 김태은 on 12/16/24.
//

import Foundation

struct BlockListModel: Codable, Equatable, Identifiable {
    let blockId: Int64
    let memberDto: BlockedUserModel
    
    var id: Int64 {
        blockId
    }
}

struct BlockedUserModel: Codable, Equatable {
    let memberId: Int64
    let profilePicture: String?
    let nickname: String?
    let information: String?
}
