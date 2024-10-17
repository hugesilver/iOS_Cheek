//
//  HighlightModel.swift
//  CHEEK
//
//  Created by 김태은 on 10/11/24.
//

import Foundation

struct HighlightListModel: Identifiable, Codable {
    let highlightId: Int64
    let thhumbnailPicture: String
    let subject: String
    
    var id: Int64 { highlightId }
}
