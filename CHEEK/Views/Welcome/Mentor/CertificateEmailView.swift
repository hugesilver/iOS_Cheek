//
//  VerifyEmailMentorView.swift
//  CHEEK
//
//  Created by 김태은 on 6/5/24.
//

import SwiftUI


struct CertificateEmailView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var authViewModel: AuthenticationViewModel
    @Binding var navPath: NavigationPath
    var isMentor: Bool
    
    @StateObject private var viewModel = CertificateEmailMentorViewModel()
    
    // 이메일 폼
    @State private var email: String = ""
    @State var statusEmail: TextFieldForm.statuses = .normal
    @FocusState var isEmailFocused: Bool
    @State private var isEmailValidated: Bool = false
    
    // 인증번호 폼
    @State private var verificationCode: String = ""
    @State var statusVerificationCode: TextFieldForm.statuses = .normal
    @FocusState var isVerificationCodeFocused: Bool
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Image("IconChevronLeft")
                        .foregroundColor(.cheekTextNormal)
                        .frame(width: 40, height: 40)
                        .onTapGesture {
                            dismiss()
                        }
                        .padding(8)
                    
                    Spacer()
                }
                .padding(.top, 8)
                
                Text("사내 이메일을 인증해주세요.")
                    .headline1(font: "SUIT", color: .cheekTextNormal, bold: true)
                    .padding(.top, 24)
                
                Text("인증을 위한 용도로만 사용됩니다.")
                    .label1(font: "SUIT", color: .cheekTextAlternative, bold: true)
                    .padding(.top, 4)
                
                VStack(spacing: 16) {
                    TextFieldForm(
                        name: "이메일",
                        placeholder: "예 > cheek@cheek.com",
                        keyboardType: .emailAddress,
                        text: $email,
                        information: .constant(""),
                        status: $statusEmail,
                        isFocused: $isEmailFocused)
                    .onChange(of: email) { _ in
                        isEmailValidated = viewModel.validateEmail(email: email)
                    }
                    .onChange(of: viewModel.isSent) { isSent in
                        if isSent {
                            statusEmail = .disabled
                        }
                    }
                    
                    if isEmailValidated && !viewModel.isVerificationCodeChecked {
                        if viewModel.isSendable {
                            ButtonActive(text: "인증번호 전송")
                                .onTapGesture {
                                    sendCode()
                                }
                        } else {
                            ButtonLine(text: "인증번호 재전송(\(String(format: "%02d:%02d", viewModel.resendTime / 60, viewModel.resendTime % 60)))")
                                .onAppear {
                                    viewModel.timerResendTime()
                                }
                        }
                    } else {
                        ButtonDisabled(text: "인증번호 전송")
                    }
                    
                    if viewModel.isSent {
                        HStack(spacing: 8) {
                            // 인증번호 입력칸
                            TextFieldForm(
                                name: "",
                                placeholder: "인증번호 입력(\(String(format: "%02d:%02d", viewModel.codeExpireTime / 60, viewModel.codeExpireTime % 60)))",
                                keyboardType: .numberPad,
                                text: $verificationCode,
                                information: .constant(""),
                                status: $statusVerificationCode,
                                isFocused: $isVerificationCodeFocused)
                            .onAppear {
                                verificationCode = ""
                                viewModel.timerCodeExpireTime()
                            }
                            .onChange(of: verificationCode) { text in
                                if text.count > 6 {
                                    verificationCode = String(text.prefix(6))
                                }
                            }
                            .onChange(of: viewModel.isVerificationCodeChecked) { isVerificationCodeChecked in
                                if isVerificationCodeChecked && viewModel.isSent {
                                    statusVerificationCode = .disabled
                                }
                            }
                            
                            // 인증하기
                            if verificationCode.count == 6 && !viewModel.isVerificationCodeChecked {
                                ButtonHugActive(text: "인증하기")
                                    .onTapGesture {
                                        verifyCode()
                                    }
                            } else {
                                ButtonHugDisabled(text: "인증하기")
                            }
                        }
                    }
                }
                .padding(.top, 16)
                
                Spacer()
                
                // 다음
                if viewModel.isSent {
                    if viewModel.isVerificationCodeChecked {
                        NavigationLink(destination: SetProfileView(authViewModel: authViewModel, navPath: $navPath, isMentor: isMentor)) {
                            ButtonActive(text: "다음")
                        }
                    } else {
                        ButtonDisabled(text: "다음")
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom,
                     isEmailFocused || isVerificationCodeFocused ? 24 : 31)
            .background(.cheekBackgroundTeritory)
            
            if viewModel.showPopup {
                EmailPopupView(showPopup: $viewModel.showPopup, authViewModel: authViewModel, navPath: $navPath, isMentor: isMentor)
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
        .onTapGesture {
            Utils().hideKeyboard()
        }
    }
    
    // 인증번호 전송
    func sendCode() {
        // 키보드 숨기기
        Utils().hideKeyboard()
        
        // 이메잃 확인 후 전송
        if viewModel.validateEmail(email: email) {
            // 도메인 검증 후 코드 전송
            viewModel.validateDomain(email: email)
        }
    }
    
    // 인증번호 확인
    func verifyCode() {
        Utils().hideKeyboard()
        
        // 인증번호 확인
        viewModel.verifyEmailCode(email: email, verificationCode: verificationCode)
    }
}

struct EmailPopupView: View {
    @Binding var showPopup: Bool
    
    @ObservedObject var authViewModel: AuthenticationViewModel
    @Binding var navPath: NavigationPath
    var isMentor: Bool
    
    var body: some View {
        VStack {
            VStack(spacing: 25) {
                VStack(spacing: 8) {
                    Text("등록되지 않은 이메일 주소입니다.")
                        .title1(font: "SUIT", color: .cheekTextStrong, bold: true)
                    
                    Text("이메일 주소를 다시 확인하거나\n이메일 주소 등록을 신청해 주세요.")
                        .body1(font: "SUIT", color: .cheekTextAlternative, bold: false)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 16) {
                    ButtonActive(text: "다시 입력")
                        .onTapGesture {
                            showPopup = false
                        }
                    
                    NavigationLink(destination: RegisterDomainView(authViewModel: authViewModel, navPath: $navPath, isMentor: isMentor)) {
                        ButtonLine(text: "이메일 등록 신청")
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 32)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.cheekWhite)
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
        .background(.black.opacity(0.4))
        .ignoresSafeArea()
    }
}

#Preview {
    CertificateEmailView(authViewModel: AuthenticationViewModel(), navPath: .constant(NavigationPath()), isMentor: true)
}
