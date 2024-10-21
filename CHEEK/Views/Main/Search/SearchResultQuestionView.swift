//
//  SearchResultQuestionView.swift
//  CHEEK
//
//  Created by 김태은 on 8/26/24.
//

import SwiftUI

struct SearchResultQuestionView: View {
    @ObservedObject var myProfileViewModel: ProfileViewModel
    @ObservedObject var searchViewModel: SearchViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(Array(searchViewModel.searchResult!.questionDto.enumerated()), id: \.offset) { index, questionDto in
                    VStack(spacing: 16) {
                        UserQuestionModelCard(
                            myProfileViewModel: myProfileViewModel,
                            questionModel: questionDto)
                        .padding(.horizontal, 16)
                        
                        if index < searchViewModel.searchResult!.questionDto.count - 1 {
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
}

#Preview {
    SearchResultQuestionView(myProfileViewModel: ProfileViewModel(), searchViewModel: SearchViewModel())
}
