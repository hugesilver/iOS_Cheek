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
    
    @State var isStoryOpen: Bool = false
    @State var selectedStories: [Int64] = []
    
    var body: some View {
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
            List(notificationViewModel.notifications) { notification in
                NotificationBlock(
                    isRead: notificationViewModel.readNotifications.contains(notification.notificationId),
                    /*
                     isLike: notification.type == "MEMBER_CONNECTION" || notification.type == "UPVOTE",
                     profilePicture: notification.profilePicture,
                     */
                    message: notification.body,
                    // date: notification.time,
                    thumbnailPicture: notification.picture,
                    onTapBakcground: {
                        onTapBackground(notification: notification)
                    }
                )
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        notificationViewModel.deleteOneNotification(notificationId: notification.notificationId)
                    } label: {
                        Text("삭제")
                    }
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
            }
            .listStyle(.plain)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.cheekBackgroundTeritory)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onAppear {
            authViewModel.isRefreshTokenValid = authViewModel.checkRefreshTokenValid()
            notificationViewModel.getNotifications()
            notificationViewModel.getReadNotifications()
        }
        .onDisappear {
            notificationViewModel.readAllNotifications()
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
    
    func onTapBackground(notification: NotificationModel) {
        switch notification.type {
        case "STORY":
            selectedStories = [notification.typeId]
            isStoryOpen = true
        default:
            break
        }
        
        notificationViewModel.setReadNotifications(notificationId: notification.notificationId)
    }
}

struct NotificationBlock: View {
    var isRead: Bool
    // let isLike: Bool
    // let profilePicture: String?
    let message: String
    // let date: String
    let thumbnailPicture: String?
    let onTapBakcground: () -> Void
    
    @State var splitedMessage: [Substring] = []
    
    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Circle()
                    .frame(width: 6, height: 6)
                    .foregroundColor(isRead ? .clear : .cheekStatusCaution)
                
                /*
                 ZStack(alignment: .bottomTrailing) {
                 ProfileM(url: profilePicture)
                 
                 Image("IconLike")
                 .frame(width: 20, height: 20)
                 }
                 .frame(width: 48, height: 48)
                 */
            }
            
            HStack(spacing: 0) {
                Text(splitedMessage.first ?? "")
                    .body2(font: "SUIT", color: .cheekTextNormal, bold: true)
                
                Text("님이" + (splitedMessage.last ?? ""))
                    .body2(font: "SUIT", color: .cheekTextNormal, bold: false)
                
                /*
                 Text("  ")
                 .body2(font: "SUIT", color: .cheekTextNormal, bold: false)
                 
                 Text(Utils().timeAgo(dateString: date) ?? "")
                 .body2(font: "SUIT", color: .cheekTextAlternative, bold: false)
                 */
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
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
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(isRead ? .clear : Color(red: 0.96, green: 0.98, blue: 1))
        .onTapGesture {
            onTapBakcground()
        }
        .onAppear {
            splitedMessage = message.split(separator: "님이")
        }
    }
}

#Preview {
    NotificationView(authViewModel: AuthenticationViewModel(), notificationViewModel: NotificationViewModel())
}
