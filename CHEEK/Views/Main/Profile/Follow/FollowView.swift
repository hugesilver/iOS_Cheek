//
//  FollowView.swift
//  CHEEK
//
//  Created by 김태은 on 10/13/24.
//

import SwiftUI

struct FollowView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var myProfileViewModel: ProfileViewModel
    @StateObject var viewModel: FollowViewModel = FollowViewModel()
    
    let targetMemberId: Int64
    @State var selectedTab: Int
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    Image("IconChevronLeft")
                        .foregroundColor(.cheekTextNormal)
                        .frame(width: 40, height: 40)
                        .onTapGesture {
                            dismiss()
                        }
                        .padding(8)
                    
                    Spacer()
                }
                .padding(.top, 8)
                .padding(.horizontal, 16)
                
                TabsText(tabs: ["팔로워", "팔로잉"], selectedTab: $selectedTab)
                
                TabView(selection: $selectedTab) {
                    ScrollView {
                        VStack(spacing: 32) {
                            if myProfileViewModel.profile != nil {
                            ForEach(viewModel.followers) { follower in
                                UserFollowCard(
                                    myProfileViewModel: myProfileViewModel,
                                    data: follower,
                                    isMe: myProfileViewModel.profile!.memberId == follower.memberId,
                                    onTapFollow: { onTapFollow(data: follower) },
                                    onTapUnfollow: { onTapUnfollow(data: follower) })
                                }
                            }
                        }
                        .padding(.vertical, 27)
                    }
                    .tag(0)
                    
                    ScrollView {
                        VStack(spacing: 32) {
                            if myProfileViewModel.profile != nil {
                            ForEach(viewModel.followings) { following in
                                UserFollowCard(
                                    myProfileViewModel: myProfileViewModel,
                                    data: following,
                                    isMe: myProfileViewModel.profile!.memberId == following.memberId,
                                    onTapFollow: { onTapFollow(data: following) },
                                    onTapUnfollow: { onTapUnfollow(data: following) })
                                }
                            }
                        }
                        .padding(.vertical, 27)
                    }
                    .tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.cheekBackgroundTeritory)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onAppear {
            getFollowers()
            getFollowings()
        }
    }
    
    func getFollowers() {
        guard let myId = myProfileViewModel.profile?.memberId else {
            print("profileViewModel에 profile이 없음")
            return
        }
        
        viewModel.getFollowers(myId: myId, targetId: targetMemberId)
    }
    
    func getFollowings() {
        guard let myId = myProfileViewModel.profile?.memberId else {
            print("profileViewModel에 profile이 없음")
            return
        }
        
        viewModel.getFollowings(myId: myId, targetId: targetMemberId)
    }
    
    func onTapFollow(data: FollowModel) {
        guard let myId = myProfileViewModel.profile?.memberId else {
            print("profileViewModel에 profile이 없음")
            return
        }
        
        // 팔로워 팔로우 상태 변경
        if let followerIndex = viewModel.followers.firstIndex(where: { $0.memberId == data.memberId }) {
            viewModel.followers[followerIndex].followerCnt += 1
            viewModel.followers[followerIndex].following = true
        }
        
        if let followingIndex = viewModel.followings.firstIndex(where: { $0.memberId == data.memberId }) {
            viewModel.followings[followingIndex].followerCnt += 1
            viewModel.followings[followingIndex].following = true
        }
        
        viewModel.follow(myId: myId, targetId: data.memberId)
    }
    
    func onTapUnfollow(data: FollowModel) {
        guard let myId = myProfileViewModel.profile?.memberId else {
            print("profileViewModel에 profile이 없음")
            return
        }
        
        // 팔로워 팔로우 상태 변경
        if let followerIndex = viewModel.followers.firstIndex(where: { $0.memberId == data.memberId }) {
            viewModel.followers[followerIndex].followerCnt -= 1
            viewModel.followers[followerIndex].following = false
        }
        
        if let followingIndex = viewModel.followings.firstIndex(where: { $0.memberId == data.memberId }) {
            viewModel.followings[followingIndex].followerCnt -= 1
            viewModel.followings[followingIndex].following = false
        }
        
        viewModel.unfollow(myId: myId, targetId: data.memberId)
    }
}

#Preview {
    FollowView(myProfileViewModel: ProfileViewModel(), targetMemberId: 1, selectedTab: 0)
}
