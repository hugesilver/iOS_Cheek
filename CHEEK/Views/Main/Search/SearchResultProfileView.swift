//
//  SearchResultProfileView.swift
//  CHEEK
//
//  Created by 김태은 on 8/26/24.
//

import SwiftUI

struct SearchResultProfileView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
//                    UserFollowCard(data: FollowModel(memberId: 0, profilePicture: "", following: true, nickname: "최대8자의닉네임", information: "대기업 출신 2년차 프로그래머입니다.", followerCnt: 64), onTapFollow: onTapFollow, onTapUnfollow: onTapUnfollow)
                    
                    DividerSmall()
                    
                    Spacer()
                }
            }
        }
        .padding(.top, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.cheekBackgroundTeritory)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
    
    func onTapFollow() {
        
    }
    
    func onTapUnfollow() {
        
    }
}

#Preview {
    SearchResultProfileView()
}
