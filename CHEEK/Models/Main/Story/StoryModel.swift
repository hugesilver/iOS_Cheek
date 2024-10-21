//
//  AnswerStoryModel.swift
//  CHEEK
//
//  Created by 김태은 on 9/12/24.
//

import Foundation

struct PostStoryModel: Codable {
    let categoryId: Int64
    let memberId: Int64
    let questionId: Int64
    let text: String
}

struct StoryModel: Identifiable, Codable {
    let storyId: Int64
    let categoryId: Int64
    let storyPicture: String
    var upvoted: Bool
    let upvoteCount: Int
    let memberDto: MemberDto
    
    var id: Int64 {
        storyId
    }
}

struct StoryDto: Identifiable, Codable, Equatable {
    let storyId: Int64
    let storyPicture: String
    let modifiedAt: String?
    var upvoted: Bool
    let upvoteCount: Int
    let categoryId: Int64?
    
    var id: Int64 {
        storyId
    }
}

struct StoryMiniDto: Identifiable, Codable {
    let storyId: Int64
    let storyPicture: String
    let modifiedAt: String
    
    var id: Int64 {
        storyId
    }
}
