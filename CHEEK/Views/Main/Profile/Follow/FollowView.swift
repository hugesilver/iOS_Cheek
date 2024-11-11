//
//  FollowView.swift
//  CHEEK
//
//  Created by 김태은 on 10/13/24.
//

import SwiftUI

struct FollowView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var stateViewModel: StateViewModel
    let targetMemberId: Int64
    @State var selectedTab: Int
    
    @State var myMemberId: Int64? = nil
    
    @StateObject var viewModel: FollowViewModel = FollowViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image("IconChevronLeft")
                    .resizable()
                    .foregroundColor(.cheekTextNormal)
                    .frame(width: 32, height: 32)
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
                                stateViewModel: stateViewModel,
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
                                stateViewModel: stateViewModel,
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
            stateViewModel.checkRefreshTokenValid()
            
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
        
        if data.memberId != nil {
            viewModel.follow(toMemberId: data.memberId!)
        }
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
        
        if data.memberId != nil {
            viewModel.unfollow(toMemberId: data.memberId!)
        }
    }
}

#Preview {
    FollowView(stateViewModel: StateViewModel(), targetMemberId: 1, selectedTab: 0)
}
