//
//  AddQuestion.swift
//  CHEEK
//
//  Created by 김태은 on 6/13/24.
//

import SwiftUI

struct AddQuestionView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var question: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(.cheekTextAssitive)
                        .frame(width: 264, height: 202)
                        .overlay(
                            VStack(spacing: 0) {
                                VStack {
                                    Text("질문을 입력하세요.")
                                        .label2(font: "SUIT", color: .cheekTextStrong, bold: true)
                                        .padding(.bottom, 15)
                                    
                                    TextField(
                                        "",
                                        text: $question,
                                        prompt:
                                            Text("질문 입력하기...")
                                            .foregroundColor(.cheekTextAlternative)
                                    )
                                    .font(
                                        Font.custom("SUIT", size: 8.5)
                                            .weight(.bold)
                                    )
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.cheekTextStrong)
                                    .padding(.horizontal, 10)
                                    .frame(height: 69)
                                    .background(
                                        RoundedRectangle(cornerRadius: 5)
                                            .foregroundColor(.cheekBackgroundTeritory)
                                    )
                                    .padding(.horizontal, 20)
                                    
                                }
                                .frame(maxHeight: .infinity)
                                .padding(.top, 44)
                                
                                Spacer()
                                
                                UnevenRoundedRectangle(cornerRadii: .init(
                                    topLeading: 0,
                                    bottomLeading: 10,
                                    bottomTrailing: 10,
                                    topTrailing: 0)
                                )
                                .foregroundColor(.cheekTextAlternative)
                                .frame(height: 37)
                                .overlay(
                                    Text("완료")
                                        .caption1(font: "SUIT", color: .cheekBackgroundTeritory, bold: true)
                                        .padding(.horizontal, 8)
                                )
                                
                            }
                        )
                        .overlay(
                            Circle()
                                .foregroundColor(.cheekTextAlternative)
                                .frame(width: 62, height: 62)
                                .alignmentGuide(.top) { $0[VerticalAlignment.center] }
                            , alignment: .top
                        )
                    
                    Text("회원님의 질문을 멘토 회원님 모두가 보고 답변할 수 있어요.")
                        .caption1(font: "SUIT", color: .cheekTextAssitive, bold: true)
                        .padding(.top, 19)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: ((UIScreen.main.bounds.size.width / 9) * 16))
            .background(.cheekBackgroundPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            .onTapGesture {
                hideKeyboard()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(
                Text("취소")
                    .label2(font: "SUIT", color: .cheekTextStrong, bold: true)
                    .padding(.leading, 24)
                    .onTapGesture {
                        presentationMode.wrappedValue.dismiss()
                    }
                , alignment: .topLeading
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
    
    // 키보드 숨기기
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    AddQuestionView()
}
