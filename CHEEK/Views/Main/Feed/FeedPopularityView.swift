//
//  FeedPopularityView.swift
//  CHEEK
//
//  Created by 김태은 on 9/3/24.
//

import SwiftUI

struct FeedPopularityView: View {
    @ObservedObject var authViewModel: AuthenticationViewModel
    @ObservedObject var profileViewModel: ProfileViewModel
    @ObservedObject var feedViewModel: FeedViewModel
    
    @Binding var isStoryOpen: Bool
    @Binding var selectedStories: [Int64]
    
    @State private var myMemberId: Int64?
    
    var onRefresh: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ForEach(Array(feedViewModel.feedPopularity.enumerated()), id: \.offset) { index, data in
                    if data.type == "STORY" {
                        UserStoryCard(authViewModel: authViewModel, storyId: data.storyDto!.storyId, storyPicture: data.storyDto!.storyPicture, modifiedAt: data.modifiedAt, memberDto: data.memberDto, isStoryOpen: $isStoryOpen, selectedStories: $selectedStories)
                        
                            .padding(.horizontal, 16)
                    }
                    
                    if data.type == "QUESTION" {
                        if myMemberId != nil {
                            VStack(spacing: 16) {
                                UserQuestionCard(
                                    authViewModel: authViewModel,
                                    profileViewModel: profileViewModel,
                                    myId: myMemberId!,
                                    questionId: data.questionDto!.questionId,
                                    content: data.questionDto!.content,
                                    storyCnt: data.questionDto!.storyCnt,
                                    modifiedAt: data.modifiedAt,
                                    memberDto: data.memberDto)
                                
                                if profileViewModel.isMentor {
                                    NavigationLink(destination: AddAnswerView(authViewModel: authViewModel, questionId: data.questionDto!.questionId)) {
                                        ButtonNarrowFill(text: "답변하기")
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    
                    if feedViewModel.feedPopularity.count - 1 > index {
                        DividerLarge()
                    }
                }
            }
            .padding(.top, 21)
            .padding(.bottom, 27)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.cheekBackgroundTeritory)
        .onAppear {
            getMyMemberId()
        }
        .refreshable {
            onRefresh()
        }
    }
    
    func getMyMemberId() {
        if let myId = Keychain().read(key: "MEMBER_ID") {
            myMemberId = Int64(myId)!
        }
    }
}

#Preview {
    FeedPopularityView(authViewModel: AuthenticationViewModel(), profileViewModel: ProfileViewModel(), feedViewModel: FeedViewModel(), isStoryOpen: .constant(false), selectedStories: .constant([]), onRefresh: {})
}
