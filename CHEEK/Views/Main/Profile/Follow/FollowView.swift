//
//  FollowView.swift
//  CHEEK
//
//  Created by 김태은 on 10/13/24.
//

import SwiftUI

struct FollowView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var authViewModel: AuthenticationViewModel
    let targetMemberId: Int64
    @State var selectedTab: Int
    
    @State var myMemberId: Int64? = nil
    
    @StateObject var viewModel: FollowViewModel = FollowViewModel()
    
    var body: some View {
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
                        ForEach(viewModel.followers) { follower in
                            UserFollowCard(
                                authViewModel: authViewModel,
                                data: follower,
                                isMe: myMemberId == follower.memberId,
                                onTapFollow: { onTapFollow(data: follower) },
                                onTapUnfollow: { onTapUnfollow(data: follower) })
                        }
                    }
                    .padding(.vertical, 27)
                }
                .tag(0)
                
                ScrollView {
                    VStack(spacing: 32) {
                        ForEach(viewModel.followings) { following in
                            UserFollowCard(
                                authViewModel: authViewModel,
                                data: following,
                                isMe: myMemberId == following.memberId,
                                onTapFollow: { onTapFollow(data: following) },
                                onTapUnfollow: { onTapUnfollow(data: following) })
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
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onAppear {
            authViewModel.isRefreshTokenValid = authViewModel.checkRefreshTokenValid()
            
            getFollowers()
            getFollowings()
            
            if let myId = Keychain().read(key: "MEMBER_ID") {
                myMemberId = Int64(myId)!
            }
        }
    }
    
    func getFollowers() {
        viewModel.getFollowers(targetMemberId: targetMemberId)
    }
    
    func getFollowings() {
        viewModel.getFollowings(targetMemberId: targetMemberId)
    }
    
    func onTapFollow(data: FollowModel) {
        // 팔로워 팔로우 상태 변경
        if let followerIndex = viewModel.followers.firstIndex(where: { $0.memberId == data.memberId }) {
            viewModel.followers[followerIndex].followerCnt += 1
            viewModel.followers[followerIndex].following = true
        }
        
        if let followingIndex = viewModel.followings.firstIndex(where: { $0.memberId == data.memberId }) {
            viewModel.followings[followingIndex].followerCnt += 1
            viewModel.followings[followingIndex].following = true
        }
        
        viewModel.follow(toMemberId: data.memberId)
    }
    
    func onTapUnfollow(data: FollowModel) {
        // 팔로워 팔로우 상태 변경
        if let followerIndex = viewModel.followers.firstIndex(where: { $0.memberId == data.memberId }) {
            viewModel.followers[followerIndex].followerCnt -= 1
            viewModel.followers[followerIndex].following = false
        }
        
        if let followingIndex = viewModel.followings.firstIndex(where: { $0.memberId == data.memberId }) {
            viewModel.followings[followingIndex].followerCnt -= 1
            viewModel.followings[followingIndex].following = false
        }
        
        viewModel.unfollow(toMemberId: data.memberId)
    }
}

#Preview {
    FollowView(authViewModel: AuthenticationViewModel(), targetMemberId: 1, selectedTab: 0)
}
