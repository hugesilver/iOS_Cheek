//
//  FeedResultView.swift
//  CHEEK
//
//  Created by 김태은 on 9/3/24.
//

import SwiftUI

struct FeedNewestView: View {
    @ObservedObject var profileViewModel: ProfileViewModel
    @ObservedObject var feedViewModel: FeedViewModel
    
    @Binding var isStoryOpen: Bool
    @Binding var selectedStories: [Int64]
    
    var onRefresh: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ForEach(Array(feedViewModel.feedNewest.enumerated()), id: \.offset) { index, data in
                    if data.type == "STORY" {
                        UserStoryCard(myProfileViewModel: profileViewModel, storyDto: data.storyDto!, memberDto: data.memberDto, date: data.modifiedAt, isStoryOpen: $isStoryOpen, selectedStories: $selectedStories)
                        
                            .padding(.horizontal, 16)
                    }
                    
                    if data.type == "QUESTION" {
                        VStack(spacing: 16) {
                            UserQuestionDtoCard(myProfileViewModel: profileViewModel, questionDto: data.questionDto!, memberDto: data.memberDto, date: data.modifiedAt)
                            
                            if profileViewModel.isMentor {
                                NavigationLink(destination: AddAnswerView(profileViewModel: profileViewModel, questionId: data.questionDto!.questionId)) {
                                    ButtonNarrowFill(text: "답변하기")
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    if index < feedViewModel.feedNewest.count - 1 {
                        DividerLarge()
                    }
                }
            }
            .padding(.top, 21)
            .padding(.bottom, 27)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.cheekBackgroundTeritory)
        .refreshable {
            onRefresh()
        }
    }
}

#Preview {
    FeedNewestView(profileViewModel: ProfileViewModel(), feedViewModel: FeedViewModel(), isStoryOpen: .constant(false), selectedStories: .constant([]), onRefresh: {})
}
