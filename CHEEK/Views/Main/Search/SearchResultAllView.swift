//
//  SearchResultAllView.swift
//  CHEEK
//
//  Created by 김태은 on 8/26/24.
//

import SwiftUI

struct SearchResultAllView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    HStack {
                        HStack(spacing: 8) {
                            Text("프로필")
                                .title1(font: "SUIT", color: .cheekTextStrong, bold: true)
                            
                            Text("999+")
                                .label2(font: "SUIT", color: .cheekTextStrong, bold: false)
                        }
                        .padding(.vertical, 10)
                        
                        Spacer()
                        
                        Text("모두 보기")
                            .label2(font: "SUIT", color: .cheekTextAlternative, bold: false)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 14)
                            .onTapGesture {
                                
                            }
                    }
                    .padding(.horizontal, 16)
                    
                    SearchResultProfileView()
                    
                    DividerLarge()
                    
                    HStack {
                        HStack(spacing: 8) {
                            Text("질문")
                                .title1(font: "SUIT", color: .cheekTextStrong, bold: true)
                            
                            Text("999+")
                                .label2(font: "SUIT", color: .cheekTextStrong, bold: false)
                        }
                        .padding(.vertical, 10)
                        
                        Spacer()
                        
                        Text("모두 보기")
                            .label2(font: "SUIT", color: .cheekTextAlternative, bold: false)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 14)
                            .onTapGesture {
                                
                            }
                    }
                    .padding(.horizontal, 16)
                    
                    SearchResultQuestionView()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.cheekBackgroundTeritory)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
}

#Preview {
    SearchResultAllView()
}
