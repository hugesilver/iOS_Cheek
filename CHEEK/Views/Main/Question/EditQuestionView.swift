//
//  EditQuestionView.swift
//  CHEEK
//
//  Created by 김태은 on 10/25/24.
//

import SwiftUI

struct EditQuestionView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var authViewModel: AuthenticationViewModel
    @ObservedObject var profileViewModel: ProfileViewModel
    
    let questionId: Int64
    var content: String
    
    @StateObject private var viewModel: QuestionViewModel = QuestionViewModel()
    
    @State private var question: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
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
                    
                    ButtonActive(text: "수정하기")
                        .onTapGesture {
                            editQuestion()
                        }
                }
                .padding(.top, 60)
                .padding(.bottom, 16)
                .padding(.horizontal, 16)
                .background(.cheekWhite)
                .cornerRadius(16)
                .overlay(
                    ProfileL(url: profileViewModel.profile?.profilePicture)
                        .alignmentGuide(.top) { $0[VerticalAlignment.center] }
                    , alignment: .top
                )
                
                Text("멘토, 멘티 모두가 질문할 수 있어요!")
                    .label1(font: "SUIT", color: .cheekTextAssitive, bold: false)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.cheekTextNormal)
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
                            dismiss()
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
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, isFocused ? 30 : 0)
        .background(.cheekTextNormal)
        .onTapGesture {
            Utils().hideKeyboard()
        }
        .onAppear {
            UINavigationBar.setAnimationsEnabled(false)
            AppState.shared.swipeEnabled = false
            
            authViewModel.checkRefreshTokenValid()
            question = content
        }
        .onDisappear {
            UINavigationBar.setAnimationsEnabled(true)
            AppState.shared.swipeEnabled = true
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text("오류"),
                message: Text(viewModel.alertMessage),
                dismissButton: .default(
                    Text("확인"),
                    action: {
                        dismiss()
                    }
                )
            )
        }
    }
    
    // 질문 추가
    func editQuestion() {
        Utils().hideKeyboard()
        
        if !question.isEmpty {
            viewModel.editQuestion(content: question, questionId: questionId) { isSuccess in
                if isSuccess {
                    print(isSuccess)
                }
            }
            
            dismiss()
        }
    }
}

#Preview {
    EditQuestionView(authViewModel: AuthenticationViewModel(), profileViewModel: ProfileViewModel(), questionId: 0, content: "")
}
