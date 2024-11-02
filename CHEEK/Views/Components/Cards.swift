//
//  Cards.swift
//  CHEEK
//
//  Created by 김태은 on 8/26/24.
//

import SwiftUI

struct RankingCard: View {
    @ObservedObject var authViewModel: AuthenticationViewModel
    
    var rank: Int
    var data: MemberProfileModel
    
    var body: some View {
        VStack(spacing: 16) {
            NavigationLink(destination: ProfileView(targetMemberId: data.memberId, authViewModel: authViewModel)) {
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
    @ObservedObject var authViewModel: AuthenticationViewModel
    
    var data: FollowModel
    var isMe: Bool
    var onTapFollow: () -> Void
    var onTapUnfollow: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                NavigationLink(destination: ProfileView(targetMemberId: data.memberId, authViewModel: authViewModel)) {
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
    @ObservedObject var authViewModel: AuthenticationViewModel
    
    let memberId: Int64
    let profilePicture: String?
    
    let title: String
    let date: String?
    
    var body: some View {
        NavigationLink(destination: ProfileView(targetMemberId: memberId, authViewModel: authViewModel)) {
            HStack(spacing: 8) {
                ProfileM(url: profilePicture ?? "")
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .body1(font: "SUIT", color: .cheekTextNormal, bold: true)
                        .lineLimit(1)
                    
                    Text(date ?? "")
                        .label2(font: "SUIT", color: .cheekTextAlternative, bold: false)
                        .lineLimit(1)
                }
                
                Spacer()
            }
        }
    }
}

struct QuestionCard: View {
    @ObservedObject var authViewModel: AuthenticationViewModel
    
    let myId: Int64
    
    let questionId: Int64
    let content: String
    let storyCnt: Int64
    let memberId: Int64
    
    @State var isEditQuestionOpen: Bool = false
    @State var showAlert: Bool = false
    
    var body: some View {
        VStack(spacing: 16) {
            Text(verbatim: content)
                .body1(font: "SUIT", color: .cheekTextNormal, bold: false)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                NavigationLink(destination: AnsweredQuestionView(authViewModel: authViewModel, questionId: questionId)) {
                    Text("답변 \(storyCnt)")
                        .label1(font: "SUIT", color: .cheekTextAlternative, bold: true)
                        .overlay(
                            Rectangle()
                                .foregroundColor(.cheekTextAlternative)
                                .frame(height: 1)
                                .offset(y: 1)
                            , alignment: .bottom
                        )
                }
                
                Spacer()
                
                if myId == memberId {
                    Menu {
                        Button(action: {
                            isEditQuestionOpen = true
                        }) {
                            Text("질문 수정")
                        }
                        
                        /*
                         Button(role: .destructive, action: {
                         
                         }) {
                         Text("질문 삭제")
                         }
                         */
                    } label: {
                        Image("IconMore")
                            .resizable()
                            .foregroundColor(.cheekTextAlternative)
                            .frame(width: 32, height: 32)
                    }
                    
                    NavigationLink(destination: EditQuestionView(authViewModel: authViewModel, questionId: questionId, content: content), isActive: $isEditQuestionOpen) {
                        EmptyView()
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .foregroundColor(.cheekLineAlternative)
        )
    }
}

struct QuestionCardWithoutOption: View {
    let questionId: Int64
    let content: String
    let memberId: Int64
    
    @State var isEditQuestionOpen: Bool = false
    @State var showAlert: Bool = false
    
    var body: some View {
        VStack(spacing: 16) {
            Text(verbatim: content)
                .body1(font: "SUIT", color: .cheekTextNormal, bold: false)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .foregroundColor(.cheekLineAlternative)
        )
    }
}

struct UserQuestionCard: View {
    @ObservedObject var authViewModel: AuthenticationViewModel
    
    let myId: Int64
    
    let questionId: Int64
    let content: String
    let storyCnt: Int64
    let modifiedAt: String
    let memberDto: MemberDto
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            UserCardLarge(
                authViewModel: authViewModel,
                memberId: memberDto.memberId,
                profilePicture: memberDto.profilePicture,
                title: "\(memberDto.nickname)님의 질문입니다!",
                date: Utils().timeAgo(dateString: modifiedAt)
            )
            
            QuestionCard(authViewModel: authViewModel, myId: myId, questionId: questionId, content: content, storyCnt: storyCnt, memberId: memberDto.memberId)
        }
    }
}

struct UserQuestionCardWithoutOption: View {
    @ObservedObject var authViewModel: AuthenticationViewModel
    
    let questionId: Int64
    let content: String
    let modifiedAt: String
    let memberDto: MemberDto
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            UserCardLarge(
                authViewModel: authViewModel,
                memberId: memberDto.memberId,
                profilePicture: memberDto.profilePicture,
                title: "\(memberDto.nickname)님의 질문입니다!",
                date: Utils().timeAgo(dateString: modifiedAt)
            )
            
            QuestionCardWithoutOption(questionId: questionId, content: content, memberId: memberDto.memberId)
        }
    }
}

struct StoryCard: View {
    let storyId: Int64
    let storyPicture: String
    
    @Binding var isStoryOpen: Bool
    @Binding var selectedStories: [Int64]
    
    var body: some View {
        AsyncImage(url: URL(string: storyPicture)) { image in
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
            selectedStories = [storyId]
            isStoryOpen = true
        }
    }
}

struct UserStoryCard: View {
    @ObservedObject var authViewModel: AuthenticationViewModel
    
    let storyId: Int64
    let storyPicture: String
    let modifiedAt: String
    var memberDto: MemberDto
    
    @Binding var isStoryOpen: Bool
    @Binding var selectedStories: [Int64]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            UserCardLarge(
                authViewModel: authViewModel,
                memberId: memberDto.memberId,
                profilePicture: memberDto.profilePicture,
                title: "\(memberDto.nickname)님의 답변입니다!",
                date: Utils().timeAgo(dateString: modifiedAt)
            )
            
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    StoryCard(storyId: storyId, storyPicture: storyPicture, isStoryOpen: $isStoryOpen, selectedStories: $selectedStories)
                }
            }
        }
    }
}
