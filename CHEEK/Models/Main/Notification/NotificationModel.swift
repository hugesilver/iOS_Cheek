//
//  NotificationModel.swift
//  CHEEK
//
//  Created by 김태은 on 10/28/24.
//

import Foundation

struct NotificationModel: Identifiable, Codable, Equatable {
    let notificationId: Int64
    let type: String
    let typeId: Int64
    let body: String
    let picture: String?
    let nickname: String
    let profilePicture: String?
    let time: String
    
    var id: Int64 {
        notificationId
    }
}
