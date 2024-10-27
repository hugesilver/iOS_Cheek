//
//  SearchResultProfileView.swift
//  CHEEK
//
//  Created by 김태은 on 8/26/24.
//

import SwiftUI

struct SearchResultProfileView: View {
    @ObservedObject var authViewModel: AuthenticationViewModel
    @ObservedObject var searchViewModel: SearchViewModel
    
    @StateObject var followViewModel = FollowViewModel()
    
    @State private var myMemberId: Int64?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(Array(searchViewModel.searchResult!.memberDto.prefix(3).enumerated()), id: \.offset) { index, memberDto in
                    VStack(spacing: 16) {
                        UserFollowCard(
                            authViewModel: authViewModel,
                            data: memberDto,
                            isMe: myMemberId == memberDto.memberId,
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
        .onAppear {
            getMyMemberId()
        }
    }
    
    func getMyMemberId() {
        if let myId = Keychain().read(key: "MEMBER_ID") {
            myMemberId = Int64(myId)!
        }
    }
    
    func onTapFollow(data: FollowModel) {
        // 팔로워 팔로우 상태 변경
        if let followerIndex = searchViewModel.searchResult!.memberDto.firstIndex(where: { $0.memberId == data.memberId }) {
            searchViewModel.searchResult!.memberDto[followerIndex].followerCnt += 1
            searchViewModel.searchResult!.memberDto[followerIndex].following = true
        }
        
        followViewModel.follow(toMemberId: data.memberId)
    }
    
    func onTapUnfollow(data: FollowModel) {
        // 팔로워 팔로우 상태 변경
        if let followerIndex = searchViewModel.searchResult!.memberDto.firstIndex(where: { $0.memberId == data.memberId }) {
            searchViewModel.searchResult!.memberDto[followerIndex].followerCnt -= 1
            searchViewModel.searchResult!.memberDto[followerIndex].following = false
        }
        
        followViewModel.unfollow(toMemberId: data.memberId)
    }
}

#Preview {
    SearchResultProfileView(authViewModel: AuthenticationViewModel(), searchViewModel: SearchViewModel())
}
