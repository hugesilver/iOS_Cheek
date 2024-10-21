//
//  SearchModel.swift
//  CHEEK
//
//  Created by 김태은 on 10/21/24.
//

import Foundation

struct SearchModel: Codable {
    var memberResCnt: Int64
    var storyResCnt: Int64
    var questionResCnt: Int64
    var memberDto: [FollowModel]
    var storyDto: [StoryMiniDto]
    var questionDto: [QuestionModel]
}
