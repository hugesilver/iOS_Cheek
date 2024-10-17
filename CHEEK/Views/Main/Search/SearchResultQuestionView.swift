//
//  SearchResultQuestionView.swift
//  CHEEK
//
//  Created by 김태은 on 8/26/24.
//

import SwiftUI

struct SearchResultQuestionView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
//                    UserQuestionCard(
//                        questionDto: QuestionDto(
//                            questionId: 0,
//                            content: "테스트 질문입니다."
//                        ),
//                        memberDto: MemberDto(memberId: 0, nickname: "테스트", profilePicture: ""),
//                        date: ""
//                    )
//                    .padding(.horizontal, 16)
                    
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
}

#Preview {
    SearchResultQuestionView()
}
