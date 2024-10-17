//
//  Cards.swift
//  CHEEK
//
//  Created by 김태은 on 8/26/24.
//

import SwiftUI

struct CaptionCard: View {
    var data: MemberProfileModel
    
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 8) {
                ProfileS(url: data.profilePicture ?? "")
                
                VStack(alignment: .leading) {
                    Text(data.nickname)
                        .body1(font: "SUIT", color: .cheekTextNormal, bold: true)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(data.description ?? "")
                        .caption1(font: "SUIT", color: .cheekTextAlternative, bold: false)
                        .lineLimit(1)
                }
                .frame(maxWidth: 188)
            }
            
            Text(data.information)
                .label2(font: "SUIT", color: .cheekTextNormal, bold: false)
                .lineLimit(1)
        }
        .frame(maxWidth: 236)
    }
}

struct RankingCard: View {
    @ObservedObject var myProfileViewModel: ProfileViewModel
    
    var rank: Int
    var data: MemberProfileModel
    
    var body: some View {
        VStack(spacing: 16) {
            NavigationLink(destination: ProfileView(targetMemberId: data.memberId, myProfileViewModel: myProfileViewModel)) {
                HStack(spacing: 8) {
                    Ranking(rank: rank)
                    
                    ProfileS(url: data.profilePicture ?? "")
                    
                    VStack(alignment: .leading) {
                        Text(data.nickname)
                            .body1(font: "SUIT", color: .cheekTextNormal, bold: true)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Text(data.description ?? "")
                            .caption1(font: "SUIT", color: .cheekTextAlternative, bold: false)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: 188)
                }
            }
            
            Text(data.information)
                .label2(font: "SUIT", color: .cheekTextNormal, bold: false)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(2)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12 + 16)
        .frame(maxWidth: 268)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(.cheekTextAssitive, lineWidth: 1)
                .foregroundColor(.cheekBackgroundTeritory)
        )
    }
}

struct UserFollowCard: View {
    @ObservedObject var myProfileViewModel: ProfileViewModel
    
    var data: FollowModel
    var isMe: Bool
    var onTapFollow: () -> Void
    var onTapUnfollow: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                NavigationLink(destination: ProfileView(targetMemberId: data.memberId, myProfileViewModel: myProfileViewModel)) {
                    HStack(spacing: 8) {
                        ProfileS(url: data.profilePicture ?? "")
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(data.nickname)
                                .body1(font: "SUIT", color: .cheekTextNormal, bold: true)
                                .lineLimit(1)
                            
                            Text("팔로워 \(data.followerCnt)")
                                .caption1(font: "SUIT", color: .cheekTextAlternative, bold: false)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                    }
                }
                
                Text(data.information)
                    .label2(font: "SUIT", color: .cheekTextNormal, bold: false)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(1)
            }
            .frame(maxWidth: 236)
            
            Spacer()
            
            if !isMe {
                if data.following {
                    ButtonNarrowDisabled(text: "언팔로우")
                        .onTapGesture {
                            onTapUnfollow()
                        }
                } else {
                    ButtonNarrowHug(text: "팔로우")
                        .onTapGesture {
                            onTapFollow()
                        }
                }
            }
        }
        .padding(.horizontal, 16)
    }
}

struct UserCardLarge: View {
    @ObservedObject var myProfileViewModel: ProfileViewModel
    
    var data: MemberDto
    var title: String
    var date: String?
    
    var body: some View {
        NavigationLink(destination: ProfileView(targetMemberId: data.memberId, myProfileViewModel: myProfileViewModel)) {
            HStack(spacing: 8) {
                ProfileM(url: data.profilePicture ?? "")
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .body1(font: "SUIT", color: .cheekTextNormal, bold: true)
                        .lineLimit(1)
                    
                    Text(date ?? "")
                        .label2(font: "SUIT", color: .cheekTextAlternative, bold: false)
                        .lineLimit(1)
                }
            }
        }
    }
}

struct QuestionCard: View {
    var question: String
    
    var body: some View {
        Text(verbatim: question)
            .body1(font: "SUIT", color: .cheekTextNormal, bold: false)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(.cheekLineAlternative)
            )
    }
}

struct UserQuestionCard: View {
    @ObservedObject var myProfileViewModel: ProfileViewModel
    
    var questionDto: QuestionDto
    var memberDto: MemberDto
    var date: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            UserCardLarge(myProfileViewModel: myProfileViewModel, data: memberDto, title: "\(memberDto.nickname)님의 질문입니다!", date: Utils().timeAgo(dateString: date))
            
            QuestionCard(question: questionDto.content)
        }
    }
}

struct StoryCard: View {
    var storyDto: StoryDto
    
    @Binding var isStoryOpen: Bool
    @Binding var selectedStories: [Int64]
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                AsyncImage(url: URL(string: storyDto.storyPicture)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(
                            width: 160,
                            height: 240
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                } placeholder: {
                    Color.cheekMainNormal
                    .frame(
                        width: 160,
                        height: 240
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedStories = [storyDto.storyId]
                    isStoryOpen = true
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

struct UserStoryCard: View {
    @ObservedObject var myProfileViewModel: ProfileViewModel
    
    var storyDto: StoryDto
    var memberDto: MemberDto
    var date: String
    
    @Binding var isStoryOpen: Bool
    @Binding var selectedStories: [Int64]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            UserCardLarge(myProfileViewModel: myProfileViewModel, data: memberDto, title: "\(memberDto.nickname)님의 답변입니다!", date: Utils().timeAgo(dateString: date))
            
            StoryCard(storyDto: storyDto, isStoryOpen: $isStoryOpen, selectedStories: $selectedStories)
        }
    }
}
