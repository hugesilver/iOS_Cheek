//
//  SelectMentorMentee.swift
//  CHEEK
//
//  Created by 김태은 on 5/26/24.
//

import SwiftUI

struct MentorMenteeView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var navPath: NavigationPath
    @Binding var isMentor: Bool?
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image("IconChevronLeft")
                    .resizable()
                    .foregroundColor(.cheekTextNormal)
                    .frame(width: 40, height: 40)
                    .onTapGesture {
                        dismiss()
                    }
                    .padding(8)
                
                Spacer()
            }
            .padding(.top, 8)
            
            Text("당신은 멘토인가요? 멘티인가요?")
                .headline1(font: "SUIT", color: .cheekTextNormal, bold: true)
                .padding(.top, 28)
            
            // 멘토
            VStack(spacing: 20) {
                // 멘토
                SelectableCard(
                    isSelect: isMentor ?? false,
                    title: "멘토",
                    description: "직장 혹은 개인 명함을 인증하고\n멘티의 질문에 답변을 할 수 있어요.")
                .onTapGesture {
                    isMentor = true
                }
                
                SelectableCard(
                    isSelect: isMentor != nil ? !isMentor! : false,
                    title: "멘티",
                    description: "멘토들에게 질문을 하고\n도움이 되는 답변을 얻어갈 수 있어요.")
                .onTapGesture {
                    isMentor = false
                }
            }
            .padding(.top, 52)
            
            Spacer()
            
            // 다음 버튼
            if isMentor != nil {
                ButtonActive(text: "다음")
                    .onTapGesture {
                        if isMentor! {
                            navPath.append("VerifyMentorView")
                        } else {
                            navPath.append("SetProfileView")
                        }
                    }
            } else {
                ButtonDisabled(text: "다음")
            }
        }
        .padding(.bottom, 40)
        .padding(.horizontal, 16)
        .background(.cheekBackgroundTeritory)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
}

#Preview {
    MentorMenteeView(navPath: .constant(NavigationPath()), isMentor: .constant(nil))
}
