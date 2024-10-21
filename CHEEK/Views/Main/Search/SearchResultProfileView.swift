//
//  SearchResultProfileView.swift
//  CHEEK
//
//  Created by 김태은 on 8/26/24.
//

import SwiftUI

struct SearchResultProfileView: View {
    @ObservedObject var myProfileViewModel: ProfileViewModel
    @ObservedObject var searchViewModel: SearchViewModel
    
    @StateObject var followViewModel = FollowViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(Array(searchViewModel.searchResult!.memberDto.prefix(3).enumerated()), id: \.offset) { index, memberDto in
                    VStack(spacing: 16) {
                        UserFollowCard(
                            myProfileViewModel: myProfileViewModel,
                            data: memberDto,
                            isMe: myProfileViewModel.profile!.memberId == memberDto.memberId,
                            onTapFollow: { onTapFollow(data: memberDto) },
                            onTapUnfollow: { onTapUnfollow(data: memberDto) }
                        )
                        
                        if index < searchViewModel.searchResult!.memberDto.count - 1 {
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

#Preview {
    SearchResultProfileView(myProfileViewModel: ProfileViewModel(), searchViewModel: SearchViewModel())
}
