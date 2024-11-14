//
//  SearchResultAllView.swift
//  CHEEK
//
//  Created by 김태은 on 8/26/24.
//

import SwiftUI

struct SearchResultAllView: View {
    @ObservedObject var authViewModel: AuthenticationViewModel
    @ObservedObject var profileViewModel: ProfileViewModel
    @ObservedObject var searchViewModel: SearchViewModel
    
    @Binding var selectedTab: Int
    
    @Binding var isStoryOpen: Bool
    @Binding var selectedStories: [Int64]
    
    @StateObject var followViewModel = FollowViewModel()
    
    @State private var myMemberId: Int64?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack {
                    HStack(spacing: 8) {
                        Text("프로필")
                            .label1(font: "SUIT", color: .cheekTextStrong, bold: true)
                        
                        Text("\(Utils().formatKoreanNumber(number: searchViewModel.searchResult!.memberResCnt))")
                            .label2(font: "SUIT", color: .cheekTextStrong, bold: false)
                    }
                    .padding(.vertical, 10)
                    
                    Spacer()
                    
                    Button(action: {
                        selectedTab = 1
                    }) {
                        Text("모두 보기")
                            .label2(font: "SUIT", color: .cheekTextAlternative, bold: false)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 14)
                    }
                }
                .padding(.horizontal, 16)
                
                ForEach(Array(searchViewModel.searchResult!.memberDto.prefix(3).enumerated()), id: \.offset) { index, memberDto in
                    VStack(spacing: 16) {
                        UserFollowCard(
                            authViewModel: authViewModel,
                            data: memberDto,
                            isMe: myMemberId == memberDto.memberId,
                            onTapFollow: { onTapFollow(data: memberDto) },
                            onTapUnfollow: { onTapUnfollow(data: memberDto) }
                        )
                        
                        if index < searchViewModel.searchResult!.memberDto.prefix(3).count - 1 {
                            DividerSmall()
                        }
                    }
                }
                
                DividerLarge()
                
                HStack {
                    HStack(spacing: 8) {
                        Text("스토리")
                            .label1(font: "SUIT", color: .cheekTextStrong, bold: true)
                        
                        Text("\(Utils().formatKoreanNumber(number: searchViewModel.searchResult!.storyResCnt))")
                            .label2(font: "SUIT", color: .cheekTextStrong, bold: false)
                    }
                    .padding(.vertical, 10)
                    
                    Spacer()
                    
                    Button(action: {
                        selectedTab = 2
                    }) {
                        Text("모두 보기")
                            .label2(font: "SUIT", color: .cheekTextAlternative, bold: false)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 14)
                    }
                }
                .padding(.horizontal, 16)
                
                ScrollView(.horizontal) {
                    HStack(spacing: 8) {
                        ForEach(Array(searchViewModel.searchResult!.storyDto.prefix(10).enumerated()), id: \.offset) { index, storyDto in
                            StoryCard(storyId: storyDto.storyId, storyPicture: storyDto.storyPicture, isStoryOpen: $isStoryOpen, selectedStories: $selectedStories)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                DividerLarge()
                
                HStack {
                    HStack(spacing: 8) {
                        Text("질문")
                            .label1(font: "SUIT", color: .cheekTextStrong, bold: true)
                        
                        Text("\(Utils().formatKoreanNumber(number: searchViewModel.searchResult!.questionResCnt))")
                            .label2(font: "SUIT", color: .cheekTextStrong, bold: false)
                    }
                    .padding(.vertical, 10)
                    
                    Spacer()
                    
                    Button(action: {
                        selectedTab = 3
                    }) {
                        Text("모두 보기")
                            .label2(font: "SUIT", color: .cheekTextAlternative, bold: false)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 14)
                    }
                }
                .padding(.horizontal, 16)
                
                if myMemberId != nil {
                    ForEach(Array(searchViewModel.searchResult!.questionDto.prefix(3).enumerated()), id: \.offset) { index, questionDto in
                        VStack(spacing: 16) {
                            UserQuestionCard(authViewModel: authViewModel, profileViewModel: profileViewModel, myId: myMemberId!, questionId: questionDto.questionId, content: questionDto.content, storyCnt: questionDto.storyCnt!, modifiedAt: questionDto.modifiedAt!, memberDto: questionDto.memberDto)
                                .padding(.horizontal, 16)
                            
                            if index < searchViewModel.searchResult!.questionDto.prefix(3).count - 1 {
                                DividerSmall()
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.cheekBackgroundTeritory)
        .onAppear {
            getMyMemberId()
        }
    }
    
    func getMyMemberId() {
        if let myId = Keychain().read(key: "MEMBER_ID") {
            myMemberId = Int64(myId)!
        }
    }
    
    func onTapFollow(data: FollowModel) {
        // 팔로워 팔로우 상태 변경
        if let followerIndex = searchViewModel.searchResult!.memberDto.firstIndex(where: { $0.memberId == data.memberId }) {
            searchViewModel.searchResult!.memberDto[followerIndex].followerCnt += 1
            searchViewModel.searchResult!.memberDto[followerIndex].following = true
        }
        
        if data.memberId != nil {
            followViewModel.follow(toMemberId: data.memberId!)
        }
    }
    
    func onTapUnfollow(data: FollowModel) {
        // 팔로워 팔로우 상태 변경
        if let followerIndex = searchViewModel.searchResult!.memberDto.firstIndex(where: { $0.memberId == data.memberId }) {
            searchViewModel.searchResult!.memberDto[followerIndex].followerCnt -= 1
            searchViewModel.searchResult!.memberDto[followerIndex].following = false
        }
        
        if data.memberId != nil {
            followViewModel.unfollow(toMemberId: data.memberId!)
        }
    }
}
