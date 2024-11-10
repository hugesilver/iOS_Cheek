//
//  FeedModel.swift
//  CHEEK
//
//  Created by 김태은 on 10/14/24.
//

import Foundation

struct FeedModel: Identifiable, Codable {
    let type: String
    var modifiedAt: String
    let memberDto: MemberDto
    let storyDto: StoryDto?
    let questionDto: QuestionDto?
    
    var id: UUID {
        UUID()
    }
}
