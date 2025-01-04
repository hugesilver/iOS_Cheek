//
//  SetProfileMentorView.swift
//  CHEEK
//
//  Created by 김태은 on 6/5/24.
//

import SwiftUI

struct RegisterDomainView: View {
    @Environment(\.dismiss) private var dismiss
    
    var isDone: () -> Void
    
    @StateObject private var viewModel = RegisterDomainViewModel()
    
    // 이메일 폼
    @State private var email: String = ""
    @State var statusEmail: TextFieldForm.statuses = .normal
    @FocusState var isEmailFocused: Bool
    @State private var isEmailValidated: Bool = false
    
    @State private var showAlert: Bool = false
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image("IconChevronLeft")
                            .resizable()
                            .foregroundColor(.cheekTextNormal)
                            .frame(width: 40, height: 40)
                            .padding(4)
                    }
                    
                    Spacer()
                }
                .padding(.top, 8)
                
                Text("사내 이메일 등록을 신청합니다.")
                    .headline1(font: "SUIT", color: .cheekTextNormal, bold: true)
                    .padding(.top, 24)
                
                Text("관리자 확인 후 멘토 회원으로 전환됩니다.")
                    .label1(font: "SUIT", color: .cheekTextAlternative, bold: true)
                    .padding(.top, 4)
                
                // 이메일 입력칸
                TextFieldForm(
                    name: "이메일",
                    placeholder: "예 > cheek@cheek.com",
                    keyboardType: .emailAddress,
                    isReqired: false,
                    text: $email,
                    information: .constant(""),
                    status: $statusEmail,
                    isFocused: $isEmailFocused,
                    showHelp: true,
                    onTapHelp: {
                        showAlert = true
                    }
                )
                .onChange(of: email) { _ in
                    isEmailValidated = viewModel.validateEmail(email: email)
                }
                .padding(.top, 16)
                
                Spacer()
                
                // 인증번호 받기
                if isEmailValidated {
                    Button(action: {
                        registerDomain()
                    }) {
                        ButtonActive(text: "등록 신청하기")
                    }
                } else {
                    ButtonDisabled(text: "등록 신청하기")
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, isEmailFocused ? 24 : 31)
            .background(.cheekBackgroundTeritory)
            
            if showAlert {
                CustomAlert(
                    showAlert: $showAlert,
                    title: "입력하신 이메일 주소에서 도메인 정보만 수집됩니다.",
                    buttonText: "확인",
                    onTap: {}
                )
            }
            
            if viewModel.isSent {
                EmailregisterDoneView(time: viewModel.time)
                    .onAppear {
                        viewModel.timerExit()
                    }
            }
            
            if viewModel.isLoading {
                LoadingView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("오류"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("확인")))
        }
        .onDisappear {
            // 타이머 종료
            viewModel.cancelTimer()
        }
        .onChange(of: viewModel.isDone) { _ in
            if viewModel.isDone {
                isDone()
            }
        }
    }
    
    // 도메인 전송
    func registerDomain() {
        hideKeyboard()
        
        // 이메잃 확인 후 전송
        if viewModel.validateEmail(email: email) {
            // 도메인 검증 후 코드 전송
            viewModel.registerDomain(email: email)
        }
    }
}

struct EmailregisterDoneView: View {
    @State var time: Int
    
    var body: some View {
        VStack(spacing: 16) {
            Image("IconChecked")
                .resizable()
                .frame(width: 160, height: 160)
                .foregroundColor(.cheekMainStrong)
            
            VStack(spacing: 4) {
                Text("멘토 신청이 완료되었습니다.")
                    .headline1(font: "SUIT", color: .cheekTextStrong, bold: true)
                
                Text("멘토 회원으로 확인되면 메일을 전송드릴게요!")
                    .label1(font: "SUIT", color: .cheekTextAlternative, bold: false)
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.cheekBackgroundTeritory)
    }
}

#Preview {
    RegisterDomainView(isDone: {})
}
