//
//  HighlightModel.swift
//  CHEEK
//
//  Created by 김태은 on 10/21/24.
//

import Foundation

struct HighlightListModel: Identifiable, Codable {
    let highlightId: Int64
    let thumbnailPicture: String
    let subject: String
    
    var id: Int64 { highlightId }
}

struct HighlightModel: Codable {
    let highlightId: Int64
    let storyId: [Int64]
}
