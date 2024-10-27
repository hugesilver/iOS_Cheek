//
//  AnsweredQuestionModel.swift
//  CHEEK
//
//  Created by 김태은 on 10/25/24.
//

import Foundation

struct AnsweredQuestionModel: Identifiable, Codable {
    let modifiedAt: String
    let storyId: Int64
    let storyPicture: String
    let upvoteCount: Int64
    let memberDto: MemberDto
    let upvoted: Bool
    
    var id: Int64 {
        storyId
    }
}
