//
//  FeedsPopularityView.swift
//  CHEEK
//
//  Created by 김태은 on 9/3/24.
//

import SwiftUI

struct FeedsPopularityView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 16) {
                        UserQuestionCard(question: "test", data: ProfileModel(memberId: 0, email: "", nickname: "최대8자의닉네임", description: "대기업 출신 2년차 프로그래머 입니다.", information: "2년차 프론트엔드 개발자입니다. 혼자 성장하는 것이 아니라 함께 성장하는 이 이상부터 3줄이 될 것 같기 때문에 테스트용 입니다", profilePicture: "", role: "", status: ""))
                        
                        ButtonNarrowFill(text: "답변하기")
                    }
                    .padding(.horizontal, 16)
                    
                    DividerLarge()
                    
                    UserAnswerCard(answerImages: [""], data: ProfileModel(memberId: 0, email: "", nickname: "최대8자의닉네임", description: "대기업 출신 2년차 프로그래머 입니다.", information: "2년차 프론트엔드 개발자입니다. 혼자 성장하는 것이 아니라 함께 성장하는 이 이상부터 3줄이 될 것 같기 때문에 테스트용 입니다", profilePicture: "", role: "", status: ""))
                        .padding(.horizontal, 16)
                }
            }
        }
        .padding(.top, 21)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.cheekBackgroundTeritory)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
}

#Preview {
    FeedsPopularityView()
}