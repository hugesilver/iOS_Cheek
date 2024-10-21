//
//  SearchResultAllView.swift
//  CHEEK
//
//  Created by 김태은 on 8/26/24.
//

import SwiftUI

struct SearchResultAllView: View {
    @ObservedObject var myProfileViewModel: ProfileViewModel
    @ObservedObject var searchViewModel: SearchViewModel
    
    @Binding var selectedTab: Int
    
    @Binding var isStoryOpen: Bool
    @Binding var selectedStories: [Int64]
    
    @StateObject var followViewModel = FollowViewModel()
    
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack {
                    HStack(spacing: 8) {
                        Text("프로필")
                            .title1(font: "SUIT", color: .cheekTextStrong, bold: true)
                        
                        Text("\(Utils().formatKoreanNumber(number: searchViewModel.searchResult!.memberResCnt))")
                            .label2(font: "SUIT", color: .cheekTextStrong, bold: false)
                    }
                    .padding(.vertical, 10)
                    
                    Spacer()
                    
                    Text("모두 보기")
                        .label2(font: "SUIT", color: .cheekTextAlternative, bold: false)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 14)
                        .onTapGesture {
                            selectedTab = 1
                        }
                }
                .padding(.horizontal, 16)
                
                ForEach(Array(searchViewModel.searchResult!.memberDto.prefix(3).enumerated()), id: \.offset) { index, memberDto in
                    VStack(spacing: 16) {
                        UserFollowCard(
                            myProfileViewModel: myProfileViewModel,
                            data: memberDto,
                            isMe: myProfileViewModel.profile!.memberId == memberDto.memberId,
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
                            .title1(font: "SUIT", color: .cheekTextStrong, bold: true)
                        
                        Text("\(Utils().formatKoreanNumber(number: searchViewModel.searchResult!.storyResCnt))")
                            .label2(font: "SUIT", color: .cheekTextStrong, bold: false)
                    }
                    .padding(.vertical, 10)
                    
                    Spacer()
                    
                    Text("모두 보기")
                        .label2(font: "SUIT", color: .cheekTextAlternative, bold: false)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 14)
                        .onTapGesture {
                            selectedTab = 2
                        }
                }
                .padding(.horizontal, 16)
                
                ScrollView(.horizontal) {
                    HStack(spacing: 8) {
                        ForEach(Array(searchViewModel.searchResult!.storyDto.prefix(10).enumerated()), id: \.offset) { index, storyDto in
                            StoryCard(storyPicture: storyDto.storyPicture, storyId: storyDto.storyId, isStoryOpen: $isStoryOpen, selectedStories: $selectedStories)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                DividerLarge()
                
                HStack {
                    HStack(spacing: 8) {
                        Text("질문")
                            .title1(font: "SUIT", color: .cheekTextStrong, bold: true)
                        
                        Text("\(Utils().formatKoreanNumber(number: searchViewModel.searchResult!.questionResCnt))")
                            .label2(font: "SUIT", color: .cheekTextStrong, bold: false)
                    }
                    .padding(.vertical, 10)
                    
                    Spacer()
                    
                    Text("모두 보기")
                        .label2(font: "SUIT", color: .cheekTextAlternative, bold: false)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 14)
                        .onTapGesture {
                            selectedTab = 3
                        }
                }
                .padding(.horizontal, 16)
                
                ForEach(Array(searchViewModel.searchResult!.questionDto.prefix(3).enumerated()), id: \.offset) { index, questionDto in
                    VStack(spacing: 16) {
                        UserQuestionModelCard(
                            myProfileViewModel: myProfileViewModel,
                            questionModel: questionDto)
                        .padding(.horizontal, 16)

                        if index < searchViewModel.searchResult!.questionDto.prefix(3).count - 1 {
                            DividerSmall()
                        }
                    }
                }
            }
            .padding(.vertical, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.cheekBackgroundTeritory)
    }
    
    func onTapFollow(data: FollowModel) {
        guard let myId = myProfileViewModel.profile?.memberId else {
            print("profileViewModel에 profile이 없음")
            return
        }
        
        // 팔로워 팔로우 상태 변경
        if let followerIndex = searchViewModel.searchResult!.memberDto.firstIndex(where: { $0.memberId == data.memberId }) {
            searchViewModel.searchResult!.memberDto[followerIndex].followerCnt += 1
            searchViewModel.searchResult!.memberDto[followerIndex].following = true
        }
        
        followViewModel.follow(myId: myId, targetId: data.memberId)
    }
    
    func onTapUnfollow(data: FollowModel) {
        guard let myId = myProfileViewModel.profile?.memberId else {
            print("profileViewModel에 profile이 없음")
            return
        }
        
        // 팔로워 팔로우 상태 변경
        if let followerIndex = searchViewModel.searchResult!.memberDto.firstIndex(where: { $0.memberId == data.memberId }) {
            searchViewModel.searchResult!.memberDto[followerIndex].followerCnt -= 1
            searchViewModel.searchResult!.memberDto[followerIndex].following = false
        }
        
        followViewModel.unfollow(myId: myId, targetId: data.memberId)
    }
}
