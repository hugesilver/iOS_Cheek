//
//  Cards.swift
//  CHEEK
//
//  Created by 김태은 on 8/26/24.
//

import SwiftUI
import Kingfisher

struct RankingCard: View {
    @ObservedObject var authViewModel: AuthenticationViewModel
    
    var rank: Int
    var data: MemberProfileModel
    
    var body: some View {
        NavigationLink(destination: ProfileView(targetMemberId: data.memberId ?? 0, authViewModel: authViewModel)) {
            VStack(spacing: 16) {
                HStack(spacing: 8) {
                    Ranking(rank: rank)
                    
                    ProfileS(url: data.profilePicture)
                    
                    VStack(alignment: .leading) {
                        Text(data.nickname ?? "알 수 없는 사용자")
                            .body1(font: "SUIT", color: .cheekTextNormal, bold: true)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Spacer()
                        
                        Text(data.description ?? "")
                            .caption1(font: "SUIT", color: .cheekTextAlternative, bold: false)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxWidth: 188)
                }
                
                Text(data.information ?? "")
                    .label2(font: "SUIT", color: .cheekTextNormal, bold: false)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .frame(width: 268)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(.cheekTextAssitive, lineWidth: 1)
                    .foregroundColor(.cheekBackgroundTeritory)
            )
        }
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
                NavigationLink(destination: ProfileView(targetMemberId: data.memberId ?? 0, authViewModel: authViewModel)) {
                    HStack(spacing: 8) {
                        ProfileS(url: data.profilePicture)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(data.nickname ?? "알 수 없는 사용자")
                                .body1(font: "SUIT", color: .cheekTextNormal, bold: true)
                                .lineLimit(1)
                            
                            Text("팔로워 \(data.followerCnt)")
                                .caption1(font: "SUIT", color: .cheekTextAlternative, bold: false)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                    }
                }
                
                Text(data.information ?? "")
                    .label2(font: "SUIT", color: .cheekTextNormal, bold: false)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(1)
            }
            .frame(maxWidth: 236)
            
            Spacer()
            
            if !isMe {
                if data.following {
                    Button(action: {
                        onTapUnfollow()
                    }) {
                        ButtonNarrowHugDisabled(text: "언팔로우")
                    }
                } else {
                    Button(action: {
                        onTapFollow()
                    }) {
                        ButtonNarrowHugActive(text: "팔로우")
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }
}

struct UserCardLarge: View {
    @ObservedObject var authViewModel: AuthenticationViewModel
    
    let objectType: String
    let objectId: Int64
    
    let memberId: Int64
    let profilePicture: String?
    
    let title: String
    let date: String?
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            NavigationLink(destination: ProfileView(targetMemberId: memberId, authViewModel: authViewModel)) {
                ProfileM(url: profilePicture)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(title)
                            .body1(font: "SUIT", color: .cheekTextNormal, bold: true)
                            .lineLimit(1)
                        
                        Spacer()
                    }
                    
                    Text(date ?? "")
                        .label2(font: "SUIT", color: .cheekTextAlternative, bold: false)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Menu {
                NavigationLink(destination: ReportView(authViewModel: authViewModel, category: objectType, categoryId: objectId, toMemberId: memberId)) {
                    Text("신고")
                }
            } label: {
                Image("IconMore")
                    .resizable()
                    .foregroundColor(.cheekTextNormal)
                    .frame(width: 32, height: 32)
            }
    }
    }
}

struct QuestionCard: View {
    @ObservedObject var authViewModel: AuthenticationViewModel
    @ObservedObject var profileViewModel: ProfileViewModel
    
    let myId: Int64
    
    let questionId: Int64
    let content: String
    let storyCnt: Int64
    let memberId: Int64?
    
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
                        NavigationLink(destination: EditQuestionView(authViewModel: authViewModel, profileViewModel: profileViewModel, questionId: questionId, content: content)) {
                            Text("질문 수정")
                        }
                    } label: {
                        Image("IconMore")
                            .resizable()
                            .foregroundColor(.cheekTextAlternative)
                            .frame(width: 32, height: 32)
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
    let memberId: Int64?
    
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
    @ObservedObject var profileViewModel: ProfileViewModel
    
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
                objectType: "QUESTION",
                objectId: questionId,
                memberId: memberDto.memberId ?? 0,
                profilePicture: memberDto.profilePicture,
                title: "\(memberDto.nickname ?? "알 수 없는 사용자")님의 질문입니다!",
                date: Utils().timeAgo(dateString: modifiedAt) ?? ""
            )
            
            QuestionCard(authViewModel: authViewModel, profileViewModel: profileViewModel, myId: myId, questionId: questionId, content: content, storyCnt: storyCnt, memberId: memberDto.memberId)
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
                objectType: "QUESTION",
                objectId: questionId,
                memberId: memberDto.memberId ?? 0,
                profilePicture: memberDto.profilePicture,
                title: "\(memberDto.nickname ?? "알 수 없는 사용자")님의 질문입니다!",
                date: Utils().timeAgo(dateString: modifiedAt) ?? ""
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
        KFImage(URL(string: storyPicture))
            .placeholder {
                Color.cheekMainNormal
            }
            .retry(maxCount: 2, interval: .seconds(2))
            .onSuccess { result in
                
            }
            .onFailure { error in
                print("\(storyPicture) 이미지 불러오기 실패: \(error)")
            }
            .resizable()
            .cancelOnDisappear(true)
            .aspectRatio(contentMode: .fill)
            .frame(width: 160, height: 240)
            .clipShape(RoundedRectangle(cornerRadius: 16))
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
                objectType: "STORY",
                objectId: storyId,
                memberId: memberDto.memberId ?? 0,
                profilePicture: memberDto.profilePicture,
                title: "\(memberDto.nickname ?? "알 수 없는 사용자")님의 답변입니다!",
                date: Utils().timeAgo(dateString: modifiedAt) ?? ""
            )
            
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    StoryCard(storyId: storyId, storyPicture: storyPicture, isStoryOpen: $isStoryOpen, selectedStories: $selectedStories)
                }
            }
        }
    }
}
