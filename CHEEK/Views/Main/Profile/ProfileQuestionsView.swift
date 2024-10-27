//
//  ProfileQuestionsView.swift
//  CHEEK
//
//  Created by 김태은 on 8/27/24.
//

import SwiftUI

struct ProfileQuestionsView: View {
    @ObservedObject var authViewModel: AuthenticationViewModel
    var questions: [QuestionDto]
    
    @State private var myMemberId: Int64? = nil
    
    var body: some View {
        VStack(spacing: 12) {
            if myMemberId != nil {
                ForEach(questions) { question in
                    QuestionCard(authViewModel: authViewModel, myId: myMemberId!, questionId: question.questionId, content: question.content, storyCnt: question.storyCnt, memberId: myMemberId!)
                }
            }
            
            Spacer()
        }
        .padding(.top, 16)
        .padding(.horizontal, 16)
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
    ProfileQuestionsView(authViewModel: AuthenticationViewModel(), questions: [])
}
