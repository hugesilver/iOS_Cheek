//
//  FeedsResultView.swift
//  CHEEK
//
//  Created by 김태은 on 9/3/24.
//

import SwiftUI

struct FeedsNewestView: View {
    @ObservedObject var profileViewModel: ProfileViewModel
    
    var datas: [FeedModel]
    
    @Binding var isStoryOpen: Bool
    @Binding var selectedStories: [Int64]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    ForEach(Array(zip(datas.indices, datas)), id: \.0) { index, data in
                        Group {
                            if data.type == "STORY" {
                                UserStoryCard(myProfileViewModel: profileViewModel, storyDto: data.storyDto!, memberDto: data.memberDto, date: data.modifiedAt, isStoryOpen: $isStoryOpen, selectedStories: $selectedStories)
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
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        if index < datas.count - 1 {
                            DividerLarge()
                        }
                    }
                }
                .padding(.bottom, 27)
            }
        }
        .padding(.top, 21)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.cheekBackgroundTeritory)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
}

#Preview {
    FeedsNewestView(profileViewModel: ProfileViewModel(), datas: [], isStoryOpen: .constant(false), selectedStories: .constant([]))
}
