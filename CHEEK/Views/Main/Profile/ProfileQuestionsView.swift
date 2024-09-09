//
//  ProfileQuestionsView.swift
//  CHEEK
//
//  Created by 김태은 on 8/27/24.
//

import SwiftUI

struct ProfileQuestionsView: View {
    var body: some View {
        VStack(spacing: 12) {
            QuestionCard(question: "test")
            QuestionCard(question: "test")
            
            Spacer()
        }
        .padding(.top, 16)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.cheekBackgroundTeritory)
    }
}

#Preview {
    ProfileQuestionsView()
}
