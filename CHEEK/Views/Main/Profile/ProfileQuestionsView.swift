//
//  ProfileQuestionsView.swift
//  CHEEK
//
//  Created by 김태은 on 8/27/24.
//

import SwiftUI

struct ProfileQuestionsView: View {
    var questions: [QuestionDto]
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(questions) { question in
                QuestionCard(question: question.content)
            }
            
            Spacer()
        }
        .padding(.top, 16)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.cheekBackgroundTeritory)
    }
}

#Preview {
    ProfileQuestionsView(questions: [])
}
