//
//  NotificationView.swift
//  CHEEK
//
//  Created by 김태은 on 10/28/24.
//

import SwiftUI

struct NotificationView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var authViewModel: AuthenticationViewModel
    @ObservedObject var notificationViewModel: NotificationViewModel
    
    enum DestinationType {
        case profile
    }
    
    @State var isPresented: Bool = false
    @State var destinationType: DestinationType = .profile
    @State var targetMemberId: Int64 = 0
    
    @State var isStoryOpen: Bool = false
    @State var selectedStories: [Int64] = []
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 상단바
                HStack {
                    Image("IconChevronLeft")
                        .foregroundColor(.cheekTextNormal)
                        .frame(width: 32, height: 32)
                        .onTapGesture {
                            dismiss()
                        }
                        .padding(8)
                    
                    Spacer()
                    
                    Text("모두 삭제")
                        .title1(font: "SUIT", color: .cheekMainStrong, bold: true)
                        .padding(.horizontal, 2)
                        .padding(.vertical, 12)
                        .onTapGesture {
                            notificationViewModel.deleteAllNotifications()
                        }
                }
                .overlay(
                    Text("활동")
                        .title1(font: "SUIT", color: .cheekTextNormal, bold: true)
                    , alignment: .center
                )
                .padding(.top, 8)
                .padding(.horizontal, 16)
                
                // 목록
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(notificationViewModel.notifications) { notification in
                            NotificationBlock(
                                isRead: notificationViewModel.readNotifications.contains(notification.notificationId),
                                isLike: notification.type == "MEMBER_CONNECTION" || notification.type == "UPVOTE",
                                profilePicture: notification.profilePicture,
                                nickname: notification.nickname,
                                message: notificationMessage(type: notification.type),
                                date: notification.time,
                                thumbnailPicture: notification.picture,
                                onTapProfile: {
                                    destinationType = .profile
                                    targetMemberId = notification.typeId
                                    isPresented = true
                                },
                                onTapThumbnail: {
                                    selectedStories = [notification.typeId]
                                    isStoryOpen = true
                                },
                                onTapBakcground: {
                                    notificationViewModel.setReadNotifications(notificationId: notification.notificationId)
                                }
                            )
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    notificationViewModel.deleteOneNotification(notificationId: notification.notificationId)
                                } label: {
                                    Text("삭제")
                                }
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.cheekBackgroundTeritory)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.cheekBackgroundTeritory)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $isPresented) {
            switch destinationType {
            case .profile:
                ProfileView(targetMemberId: targetMemberId, authViewModel: authViewModel)
            }
        }
        .onAppear {
            authViewModel.isRefreshTokenValid = authViewModel.checkRefreshTokenValid()
            notificationViewModel.getNotifications()
        }
        .fullScreenCover(isPresented: $isStoryOpen) {
            if #available(iOS 16.4, *) {
                StoryView(authViewModel: authViewModel, storyIds: $selectedStories)
                    .presentationBackground(.clear)
            } else {
                StoryView(authViewModel: authViewModel, storyIds: $selectedStories)
            }
        }
    }
    
    func notificationMessage(type: String) -> String {
        switch type {
        case "ROLE":
            return "님, 멘토 회원 승인이 정상적으로 완료되었어요!"
        case "MEMBER_CONNECTION":
            return "님이 나를 팔로우했어요."
        case "STORY":
            return "님이 내 질문에 스토리로 답변했어요."
        case "UPVOTE":
            return "님이 내 스토리에 좋아요를 표시했어요."
        case "NONE":
            return ""
        default: return ""
        }
    }
}

struct NotificationBlock: View {
    var isRead: Bool
    let isLike: Bool
    let profilePicture: String?
    let nickname: String
    let message: String
    let date: String
    let thumbnailPicture: String?
    
    let onTapProfile: () -> Void
    let onTapThumbnail: () -> Void
    let onTapBakcground: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Circle()
                    .frame(width: 6, height: 6)
                    .foregroundColor(isRead ? .clear : .cheekStatusCaution)
                
                ZStack(alignment: .bottomTrailing) {
                    ProfileM(url: profilePicture ?? "")
                    
                    Image("IconLike")
                        .frame(width: 20, height: 20)
                }
                .frame(width: 48, height: 48)
                .onTapGesture {
                    onTapProfile()
                }
            }
            
            HStack(spacing: 0) {
                Text(nickname)
                    .body2(font: "SUIT", color: .cheekTextNormal, bold: true)

                Text(message)
                    .body2(font: "SUIT", color: .cheekTextNormal, bold: false)
                
                Text("  ")
                    .body2(font: "SUIT", color: .cheekTextNormal, bold: false)

                Text(Utils().timeAgo(dateString: date) ?? "")
                    .body2(font: "SUIT", color: .cheekTextAlternative, bold: false)
            }
            
            if thumbnailPicture != nil {
                AsyncImage(url: URL(string: thumbnailPicture!)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image("ImageDefaultProfile")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
                .frame(width: 48, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .onTapGesture {
                    onTapThumbnail()
                }
            }
        }
        .padding(16)
        .background(isRead ? .clear : Color(red: 0.96, green: 0.98, blue: 1))
        .onTapGesture {
            onTapBakcground()
        }
    }
}

#Preview {
    NotificationView(authViewModel: AuthenticationViewModel(), notificationViewModel: NotificationViewModel())
}
