//
//  SelectMentorMentee.swift
//  CHEEK
//
//  Created by 김태은 on 5/26/24.
//

import SwiftUI

struct SelectMentorMenteeView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var socialProvider: String
    
    @State var isMentor: Bool = true
    @State var isDone: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Image("IconArrowLeft")
                        .frame(width: 24, height: 24)
                        .onTapGesture {
                            presentationMode.wrappedValue.dismiss()
                        }
                    
                    Spacer()
                }
                .padding(.bottom, 24)
                
                Text("당신은 멘토인가요? 멘티인가요?")
                    .title1(font: "SUIT", color: .cheekTextStrong, bold: true)
                    .padding(.bottom, 64)
                
                // 멘토
                VStack(spacing: 12) {
                    Text("멘토")
                        .title1(font: "SUIT", color: .cheekTextStrong, bold: true)
                    
                    Text("직장 이메일 인증 후 멘티의 질문에\n답변하며 조언을 줄 수 있어요.")
                        .label2(font: "SUIT", color: .cheekTextStrong, bold: false)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 108)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(isMentor == true ? .cheekTextAlternative : .cheekTextAssitive, lineWidth: 1)
                )
                .padding(.bottom, 24)
                .padding(.horizontal, 25)
                .onTapGesture {
                     isMentor = true
                }
                
                // 멘티
                VStack(spacing: 12) {
                    Text("멘티")
                        .title1(font: "SUIT", color: .cheekTextStrong, bold: true)
                    
                    Text("질문을 남기고 여러 명의 멘토에게\n자유롭게 답변 받을 수 있어요.")
                        .label2(font: "SUIT", color: .cheekTextStrong, bold: false)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 108)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(isMentor == false ? .cheekTextAlternative : .cheekTextAssitive, lineWidth: 1)
                )
                .padding(.horizontal, 25)
                .onTapGesture {
                    isMentor = false
                }
                
                Spacer()
                
                // 다음 버튼
                Text("다음")
                    .label1(font: "SUIT", color: .cheekTextNormal, bold: true)
                    .frame(maxWidth: .infinity)
                    .frame(height: 41)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isMentor != nil ? .cheekMainHeavy : Color(red: 0.85, green: 0.85, blue: 0.85))
                    )
                    .padding(.horizontal, 17)
                    .onTapGesture {
                        isDone = true
                    }
            }
            .padding(.top, 48)
            .padding(.bottom, 40)
            .padding(.horizontal, 23)
            .background(.cheekBackgroundTeritory)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $isDone, destination: {
            if isMentor == false {
                SetProfileView(socialProvider: $socialProvider, isMentor: $isMentor)
            } else {
                VerifyEmailMentorView(socialProvider: $socialProvider)
            }
        })
    }
}

#Preview {
    SelectMentorMenteeView(socialProvider: .constant("Kakao"))
}
