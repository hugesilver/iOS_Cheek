//
//  VerifyEmailMentorView.swift
//  CHEEK
//
//  Created by 김태은 on 6/5/24.
//

import SwiftUI

struct CertificateEmailView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var isMentor: Bool = true
    
    @StateObject private var viewModel = VerifyEmailMentorViewModel()
    
    @State private var isLoading: Bool = false
    
    @State private var email: String = ""
    @State var statusEmail: TextFieldForm.statuses = .normal
    @State private var isEmailValidated: Bool = false
    @FocusState var isEmailFocused: Bool
    
    @State private var verificationCode: String = ""
    @State var statusVerificationCode: TextFieldForm.statuses = .normal
    @FocusState var isVerificationCodeFocused: Bool
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    @State private var isSent: Bool = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var resendTime: Int = 60
    
    @State private var isSendable: Bool = true
    
    @State private var codeExpireTime: Int = 180
    @State private var codeExpireTimerRunning: Bool = false
    
    @State private var isVerificationCodeChecked: Bool = false
    
    @State private var showPopup: Bool = false
    @State private var isDone: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Image("IconChevronLeft")
                            .foregroundColor(.cheekTextNormal)
                            .frame(width: 40, height: 40)
                            .onTapGesture {
                                presentationMode.wrappedValue.dismiss()
                            }
                            .padding(4)
                        
                        Spacer()
                    }
                    .padding(.top, 12)
                    
                    Text("사내 이메일을 인증해주세요.")
                        .headline1(font: "SUIT", color: .cheekTextNormal, bold: true)
                        .padding(.top, 24)
                    
                    Text("인증을 위한 용도로만 사용됩니다.")
                        .label1(font: "SUIT", color: .cheekTextAlternative, bold: true)
                        .padding(.top, 4)
                    
                    VStack(spacing: 16) {
                        TextFieldForm(name: "이메일", placeholder: "예 > cheek@cheek.com", keyboardType: .emailAddress, text: $email, information: "", status: $statusEmail, isFocused: $isEmailFocused)
                            .onChange(of: email) { _ in
                            isEmailValidated = viewModel.validateEmail(email: email)
                        }
                            .onChange(of: isSent) { _ in
                                if isSent {
                                    statusEmail = .disabled
                                }
                            }
                        
                        if isEmailValidated && !isVerificationCodeChecked {
                            if isSendable {
                                ButtonActive(text: "인증번호 전송")
                                    .onTapGesture {
                                        hideKeyboard()
                                        
                                        if !isLoading {
                                            isLoading = true
                                            if viewModel.validateEmail(email: email) {
                                                viewModel.validateDomain(email: email) { result in
                                                    if result {
                                                        viewModel.sendEmail(email: email) { response in
                                                            if response != nil && response == "ok" {
                                                                isSent = true
                                                                isSendable = false
                                                                codeExpireTime = 180
                                                                codeExpireTimerRunning = true
                                                                
                                                                isLoading = false
                                                            } else {
                                                                alertMessage = "오류가 발생하였습니다.\n다시 시도해주세요."
                                                                showAlert = true
                                                                isLoading = false
                                                            }
                                                        }
                                                    } else {
                                                        showPopup = true
                                                        isLoading = false
                                                    }
                                                }
                                            } else {
                                                alertMessage = "이메일을 다시 확인해주세요."
                                                showAlert = true
                                                isLoading = false
                                            }
                                        }
                                    }
                            } else {
                                ButtonLine(text: "인증번호 재전송(\(String(format: "%02d:%02d", resendTime / 60, resendTime % 60)))")
                                    .onReceive(timer) { _ in
                                        if resendTime > 0 {
                                            resendTime -= 1
                                        } else {
                                            resendTime = 60
                                            isSendable = true
                                        }
                                    }
                            }
                        } else {
                            ButtonDisabled(text: "인증번호 전송")
                        }
                        
                        if isSent && codeExpireTimerRunning {
                            HStack(spacing: 8) {
                                // 인증번호 입력칸
                                TextFieldForm(
                                    name: "",
                                    placeholder: "인증번호 입력(\(String(format: "%02d:%02d", codeExpireTime / 60, codeExpireTime % 60)))", 
                                    keyboardType: .numberPad,
                                    text: $verificationCode,
                                    information: "",
                                    status: $statusVerificationCode,
                                    isFocused: $isVerificationCodeFocused)
                                    .onChange(of: verificationCode) { text in
                                        if text.count > 6 {
                                            verificationCode = String(text.prefix(6))
                                        }
                                    }
                                    .onChange(of: isVerificationCodeChecked) { _ in
                                        if isSent {
                                            statusVerificationCode = .disabled
                                        }
                                    }
                                    .onReceive(timer) { _ in
                                        if codeExpireTimerRunning {
                                            if codeExpireTime > 0 {
                                                codeExpireTime -= 1
                                            } else {
                                                codeExpireTime = 180
                                                verificationCode = ""
                                                isSent = false
                                                codeExpireTimerRunning = false
                                            }
                                        }
                                    }
                                
                                // 인증하기
                                if !verificationCode.isEmpty && !isVerificationCodeChecked {
                                    ButtonHugActive(text: "인증하기")
                                        .onTapGesture {
                                            if !isVerificationCodeChecked {
                                                isLoading = true
                                                viewModel.verifyEmailCode(email: email, verificationCode: verificationCode) { response in
                                                    if response != nil && response == "ok" {
                                                        isVerificationCodeChecked = true
                                                        isLoading = false
                                                    } else {
                                                        alertMessage = "인증번호를 다시 확인해주세요."
                                                        showAlert = true
                                                        isLoading = false
                                                    }
                                                }
                                            }
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
                    if isSent {
                        if isVerificationCodeChecked {
                            ButtonActive(text: "다음")
                                .onTapGesture {
                                    isDone = true
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
                
                if showPopup {
                    EmailPopupView(showPopup: $showPopup, isDone: $isDone)
                }
                
                if isLoading {
                    LoadingView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onTapGesture {
                hideKeyboard()
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $isDone, destination: {
            if isSent {
                SetProfileView(isMentor: $isMentor)
            } else {
                RegisterDomainView()
            }
        })
        .alert(isPresented: $showAlert) {
            Alert(title: Text("오류"), message: Text(alertMessage), dismissButton: .default(Text("확인")))
        }
    }
    
    // 키보드 숨기기
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct EmailPopupView: View {
    @Binding var showPopup: Bool
    @Binding var isDone: Bool
    
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
                    
                    ButtonLine(text: "이메일 등록 신청")
                        .onTapGesture {
                            isDone = true
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
    CertificateEmailView()
}
