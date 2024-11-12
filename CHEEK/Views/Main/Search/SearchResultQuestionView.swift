//
//  SearchResultQuestionView.swift
//  CHEEK
//
//  Created by 김태은 on 8/26/24.
//

import SwiftUI

struct SearchResultQuestionView: View {
    @ObservedObject var authViewModel: AuthenticationViewModel
    @ObservedObject var profileViewModel: ProfileViewModel
    @ObservedObject var searchViewModel: SearchViewModel
    
    @State private var myMemberId: Int64?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if myMemberId != nil {
                    ForEach(Array(searchViewModel.searchResult!.questionDto.enumerated()), id: \.offset) { index, questionDto in
                        VStack(spacing: 16) {
                            UserQuestionCard(
                                authViewModel: authViewModel,
                                profileViewModel: profileViewModel,
                                myId: myMemberId!,
                                questionId: questionDto.questionId,
                                content: questionDto.content,
                                storyCnt: questionDto.storyCnt!,
                                modifiedAt: questionDto.modifiedAt!,
                                memberDto: questionDto.memberDto)
                                .padding(.horizontal, 16)
                            
                            if index < searchViewModel.searchResult!.questionDto.count - 1 {
                                DividerSmall()
                            }
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
}

#Preview {
    SearchResultQuestionView(authViewModel: AuthenticationViewModel(), profileViewModel: ProfileViewModel(), searchViewModel: SearchViewModel())
}
