//
//  AnsweredQuestionModel.swift
//  CHEEK
//
//  Created by 김태은 on 10/25/24.
//

import Foundation

struct AnsweredQuestionModel: Codable {
    let modifiedAt: String
    let memberDto: MemberDto
    let storyDto: StoryDto
}
