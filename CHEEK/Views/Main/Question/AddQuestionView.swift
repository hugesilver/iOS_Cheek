//
//  AddQuestion.swift
//  CHEEK
//
//  Created by 김태은 on 6/13/24.
//

import SwiftUI

struct AddQuestionView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var categoryId: Int64
    var memberId: Int64
    
    @StateObject private var viewModel: AddQuestionViewModel = AddQuestionViewModel()
    
    @State private var question: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 질문 입력
                VStack(spacing: 16) {
                    if isFocused {
                        Spacer()
                    }
                    
                    VStack(spacing: 16) {
                        Text("질문을 입력해주세요")
                            .headline1(font: "SUIT", color: .cheekTextNormal, bold: true)
                        
                        TextField("여기에 입력해주세요...", text: $question, axis: .vertical)
                            .body1(font: "SUIT", color: .cheekTextNormal, bold: false)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                            .lineLimit(3)
                            .focused($isFocused)
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundColor(.cheekLineAlternative)
                            )
                            .onChange(of: question) { text in
                                question = String(text.prefix(50))
                            }
                        
                        ButtonActive(text: "등록하기")
                            .onTapGesture {
                                addQuestion()
                            }
                    }
                    .padding(.top, 60)
                    .padding(.bottom, 16)
                    .padding(.horizontal, 16)
                    .background(.cheekWhite)
                    .cornerRadius(16)
                    .overlay(
                        ProfileL(url: "")
                            .alignmentGuide(.top) { $0[VerticalAlignment.center] }
                        , alignment: .top
                    )
                    
                    Text("멘토 회원님 모두가 답변할 수 있어요!")
                        .label1(font: "SUIT", color: .cheekTextAssitive, bold: false)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 16)
                
                // 닫기
                VStack {
                    HStack {
                        Image("IconX")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .foregroundColor(.cheekWhite)
                            .padding(8)
                            .background(
                                Circle()
                                    .foregroundColor(Color(red: 0.29, green: 0.29, blue: 0.29).opacity(0.6))
                            )
                            .onTapGesture {
                                presentationMode.wrappedValue.dismiss()
                            }
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 16)
                .padding(.horizontal, 16)
                
                if viewModel.isLoading {
                    LoadingView()
                }
            }
            .background(.cheekTextNormal)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.bottom, isFocused ? 30 : 0)
        }
        .background(.cheekTextNormal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onTapGesture {
            hideKeyboard()
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text("오류"),
                message: Text(viewModel.alertMessage),
                dismissButton: .default(
                    Text("확인"),
                    action: {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            )
        }
    }
    
    // 키보드 숨기기
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // 질문 추가
    func addQuestion() {
        hideKeyboard()
        
        if !question.isEmpty {
            viewModel.uploadQuestion(memberId: memberId, categoryId: categoryId, content: question) { success in
                    if success {
                            presentationMode.wrappedValue.dismiss()
                    }
                }
        }
    }
}

#Preview {
    AddQuestionView(categoryId: 1, memberId: 1)
}
