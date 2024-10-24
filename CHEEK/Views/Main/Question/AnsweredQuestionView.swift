//
//  AnsweredQuestionView.swift
//  CHEEK
//
//  Created by 김태은 on 10/25/24.
//

import SwiftUI

struct AnsweredQuestionView: View {
    @Environment(\.dismiss) private var dismiss
    
    let questionId: Int64
    
    @StateObject var viewModel: QuestionViewModel = QuestionViewModel()
    @State private var isStoryOpen: Bool = false
    @State private var selectedStories: [Int64] = []
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image("IconChevronLeft")
                    .foregroundColor(.cheekTextNormal)
                    .frame(width: 32, height: 32)
                    .onTapGesture {
                        dismiss()
                    }
                    .padding(8)
                
                Spacer()
            }
            .overlay(
                Text("질문 상세")
                    .body1(font: "SUIT", color: .cheekTextNormal, bold: true)
                , alignment: .center
            )
            .padding(.top, 8)
            .padding(.horizontal, 16)
            
            ScrollView {
                VStack(spacing: 24) {
                    if viewModel.questionModel != nil {
                        UserQuestionCard(myId: myId, questionId: viewModel.questionModel!.questionId, content: viewModel.questionModel!.content, storyCnt: viewModel.questionModel!.storyCnt, modifiedAt: viewModel.questionModel!.modifiedAt!, memberDto: viewModel.questionModel!.memberDto)
                    }
                    
                    DividerLarge()
                    
                    if viewModel.answeredUserStories.count > 0 {
                        ForEach(viewModel.answeredUserStories) { story in
                            UserStoryCard(storyDto: story.storyDto, memberDto: story.memberDto, date: story.modifiedAt, isStoryOpen: $isStoryOpen, selectedStories: $selectedStories)
                        }
                    }
                }
                .padding(.vertical, 16)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.cheekBackgroundTeritory)
        .onAppear {
            viewModel.getQuestion(questionId: questionId)
            viewModel.getAnsweredQuestions(questionId: questionId)
        }
        .fullScreenCover(isPresented: $isStoryOpen) {
            if #available(iOS 16.4, *) {
                StoryView(storyIds: $selectedStories, profileViewModel: profileViewModel)
                    .presentationBackground(.clear)
            } else {
                StoryView(storyIds: $selectedStories, profileViewModel: profileViewModel)
            }
        }
    }
}

#Preview {
    AnsweredQuestionView(questionId: 1)
}
