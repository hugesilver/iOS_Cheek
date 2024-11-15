//
//  NotificationView.swift
//  CHEEK
//
//  Created by 김태은 on 10/28/24.
//

import SwiftUI
import Kingfisher

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
                Button(action: {
                    dismiss()}
                ) {
                    Image("IconChevronLeft")
                        .resizable()
                        .foregroundColor(.cheekTextNormal)
                        .frame(width: 32, height: 32)
                        .padding(8)
                }
                
                Spacer()
                
                Button(action: {
                    notificationViewModel.deleteAllNotifications()
                }) {
                    Text("모두 삭제")
                        .label1(font: "SUIT", color: .cheekMainStrong, bold: true)
                        .padding(.horizontal, 2)
                        .padding(.vertical, 12)
                }
            }
            .overlay(
                Text("활동")
                    .label1(font: "SUIT", color: .cheekTextNormal, bold: true)
                , alignment: .center
            )
            .padding(.top, 8)
            .padding(.horizontal, 16)
            
            // 목록
            List(notificationViewModel.notifications) { notification in
                let isRead: Bool = notificationViewModel.readNotifications.contains(notification.notificationId)
                
                Group {
                    if notification.type == "MEMBER_CONNECTION" {
                        NotificationBlock(
                            isRead: isRead,
                            message: notification.body,
                            thumbnailPicture: notification.picture
                        )
                        .background(
                            NavigationLink("", destination: ProfileView(targetMemberId: notification.typeId, authViewModel: authViewModel))
                                .opacity(0)
                                .simultaneousGesture(TapGesture().onEnded {
                                    onTapBackground(notification: notification)
                                })
                        )
                    } else {
                        Button(action: {
                            onTapBackground(notification: notification)
                        }) {
                            NotificationBlock(
                                isRead: isRead,
                                message: notification.body,
                                thumbnailPicture: notification.picture
                            )
                        }
                    }
                }
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
            authViewModel.checkRefreshTokenValid()
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
    let message: String
    let thumbnailPicture: String?
    
    @State var splitedMessage: [Substring] = []
    
    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Circle()
                    .frame(width: 6, height: 6)
                    .foregroundColor(isRead ? .clear : .cheekStatusCaution)
            }
            
            Group {
                if splitedMessage.count == 2 {
                    Group {
                        Text(splitedMessage.first ?? "")
                            .fontWeight(.semibold) +
                        Text("님이" + (splitedMessage.last ?? ""))
                            .fontWeight(.regular)
                    }
                    .font(.custom("SUIT", size: 15))
                    .foregroundColor(.cheekTextNormal)
                    .lineSpacing(22 - (UIFont(name: "SUIT", size: 15) ?? UIFont.systemFont(ofSize: 15)).lineHeight)
                    .tracking(0.005)
                    
                } else {
                    Text(message)
                        .body2(font: "SUIT", color: .cheekTextNormal, bold: false)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            if thumbnailPicture != nil {
                KFImage(URL(string: thumbnailPicture!))
                    .placeholder {
                        Image("ImageDefaultProfile")
                            .resizable()
                    }
                    .retry(maxCount: 2, interval: .seconds(2))
                    .onSuccess { result in
                        
                    }
                    .onFailure { error in
                        print("\(thumbnailPicture!) 이미지 불러오기 실패: \(error)")
                    }
                    .resizable()
                    .cancelOnDisappear(true)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 48, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(isRead ? .cheekBackgroundTeritory : Color(red: 0.96, green: 0.98, blue: 1))
        .onAppear {
            splitedMessage = message.split(separator: "님이")
        }
    }
}

#Preview {
    NotificationView(authViewModel: AuthenticationViewModel(), notificationViewModel: NotificationViewModel())
}
