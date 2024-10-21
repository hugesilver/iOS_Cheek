//
//  QuestionModel.swift
//  CHEEK
//
//  Created by 김태은 on 9/12/24.
//

import Foundation

struct QuestionModel: Identifiable, Codable {
    let questionId: Int64
    let content: String
    let categoryId: Int64
    let modifiedAt: String?
    let memberDto: MemberDto
    let storyCnt: Int64?
    
    var id: Int64 { questionId }
}

struct QuestionDto: Identifiable, Codable, Equatable {
    let questionId: Int64
    let content: String
    let categoryId: Int64?
    let storyCnt: Int64
    
    var id: Int64 { questionId }
}
