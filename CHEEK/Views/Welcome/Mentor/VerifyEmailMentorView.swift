//
//  VerifyEmailMentorView.swift
//  CHEEK
//
//  Created by 김태은 on 6/5/24.
//

import SwiftUI

struct VerifyEmailMentorView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var socialProvider: String
    @State private var isMentor: Bool = true
    
    @State private var email: String = ""
    @State private var verificationCodes: String = ""
    @StateObject private var viewModel = VerifyEmailMentorViewModel()
    
    @State private var isLoading: Bool = false
    
    @State private var isEmailValidated: Bool = false
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    @State private var showPopup: Bool = false
    
    @State private var isSent: Bool = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var resendTime = 60
    @State private var resendTimerRunning: Bool = false
    
    @State private var codeExpireTime = 180
    @State private var codeExpireTimerRunning: Bool = false
    
    @State private var isDone: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Image("IconArrowLeft")
                            .frame(width: 24, height: 24)
                            .onTapGesture {
                                presentationMode.wrappedValue.dismiss()
                            }
                        
                        Spacer()
                    }
                    .padding(.bottom, 24)
                    
                    Text("사내 이메일을 인증해주세요.")
                        .headline1(font: "SUIT", color: .cheekTextStrong, bold: true)
                        .padding(.bottom, 4)
                    
                    Text("인증을 위한 용도로만 사용됩니다.")
                        .caption1(font: "SUIT", color: .cheekTextAlternative, bold: true)
                        .padding(.bottom, 48)
                    
                    
                    Text("이메일")
                        .caption1(font: "SUIT", color: .cheekTextStrong, bold: true)
                        .padding(.bottom, 4)
                    
                    // 이메일 입력칸
                    TextField(
                        "",
                        text: $email,
                        prompt:
                            Text(verbatim: "예 > cheek@cheek.com")
                            .foregroundColor(.cheekTextAlternative)
                    )
                    .keyboardType(.emailAddress)
                    .disabled(showPopup || isSent)
                    .caption1(font: "SUIT", color: .cheekTextStrong, bold: true)
                    .foregroundColor(.cheekTextStrong)
                    .frame(height: 32)
                    .padding(.leading, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.cheekTextStrong, lineWidth: 1)
                    )
                    .padding(.bottom, 12)
                    .onChange(of: email) { _ in
                        isEmailValidated = viewModel.validateEmail(email: email)
                    }
                    
                    // 인증번호 받기
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(isEmailValidated && resendTime == 60 ? .cheekTextStrong : .cheekTextAssitive, lineWidth: 1)
                        .foregroundColor(.cheekBackgroundTeritory)
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                        .overlay(
                            Text(!resendTimerRunning && resendTime == 60 ? "인증번호 받기" : "전송 완료 (\(String(format: "%02d:%02d", resendTime / 60, resendTime % 60)))")
                                .caption1(font: "SUIT", color: !resendTimerRunning && isEmailValidated && resendTime == 60 ? .cheekTextStrong : .cheekTextAssitive, bold: true)
                        )
                        .padding(.bottom, 24)
                        .contentShape(Rectangle())
                        .onReceive(timer) { _ in
                            if resendTimerRunning {
                                if resendTime > 0 {
                                    resendTime -= 1
                                } else {
                                    resendTime = 60
                                    resendTimerRunning = false
                                }
                            }
                        }
                        .onTapGesture {
                            hideKeyboard()
                            
                            if !isLoading && resendTime == 60 {
                                isLoading = true
                                if viewModel.validateEmail(email: email) {
                                    viewModel.validateDomain(email: email) { result in
                                        if result {
                                            viewModel.sendEmail(email: email) { response in
                                                if response != nil && response == "ok" {
                                                    isSent = true
                                                    resendTime = 60
                                                    resendTimerRunning = true
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
                    
                    if isSent && codeExpireTimerRunning {
                        Text("인증번호")
                            .caption1(font: "SUIT", color: .cheekTextStrong, bold: true)
                            .padding(.bottom, 4)
                        
                        // 인증번호 입력칸
                        TextField(
                            "",
                            text: $verificationCodes,
                            prompt:
                                Text("인증번호 입력 (\(String(format: "%02d:%02d", codeExpireTime / 60, codeExpireTime % 60)))")
                                .foregroundColor(.cheekTextAlternative)
                        )
                        .textContentType(.oneTimeCode)
                        .keyboardType(.numberPad)
                        .disabled(showPopup)
                        .caption1(font: "SUIT", color: .cheekTextStrong, bold: true)
                        .foregroundColor(.cheekTextStrong)
                        .frame(height: 32)
                        .padding(.leading, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.cheekTextStrong, lineWidth: 1)
                        )
                        .padding(.bottom, 12)
                        .onReceive(timer) { _ in
                            if codeExpireTimerRunning {
                                if codeExpireTime > 0 {
                                    codeExpireTime -= 1
                                } else {
                                    codeExpireTime = 180
                                    verificationCodes = ""
                                    isSent = false
                                    codeExpireTimerRunning = false
                                }
                            }
                        }
                        
                        Spacer()
                        
                        // 인증 완료
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundColor(!verificationCodes.isEmpty ? .cheekMainHeavy : Color(red: 0.85, green: 0.85, blue: 0.85))
                            .frame(maxWidth: .infinity)
                            .frame(height: 41)
                            .padding(.horizontal, 17)
                            .overlay(
                                Text("인증 완료")
                                    .label1(font: "SUIT", color: .cheekTextNormal, bold: true)
                            )
                            .onTapGesture {
                                hideKeyboard()
                                
                                if !verificationCodes.isEmpty{
                                    viewModel.verifyEmailCode(email: email, verificationCode: verificationCodes) { response in
                                        if response != nil && response == "ok" {
                                            isDone = true
                                        } else {
                                            alertMessage = "인증번호를 다시 확인해주세요."
                                            showAlert = true
                                        }
                                    }
                                }
                            }
                    } else {
                        Spacer()
                    }
                }
                .padding(.top, 48)
                .padding(.bottom, 40)
                .padding(.horizontal, 23)
                .background(.cheekBackgroundTeritory)
                .blur(radius: showPopup ? 4 : 0)
                
                if showPopup {
                    Color.clear
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            
                        }
                }
                
                EmailPopupView(showPopup: $showPopup, isDone: $isDone)
                
                if isLoading {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.7))
                    .ignoresSafeArea()
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
                SetProfileView(socialProvider: $socialProvider, isMentor: $isMentor)
            } else {
                RegisterDomainView(socialProvider: $socialProvider)
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
    
    var r: CGFloat = 16
    
    var body: some View {
        VStack {
            Spacer()
            
            UnevenRoundedRectangle(cornerRadii:.init(
                topLeading: r,
                bottomLeading: 0,
                bottomTrailing: 0,
                topTrailing: r)
            )
            .stroke(.cheekTextAssitive, lineWidth: 1)
            .frame(maxWidth: .infinity)
            .frame(height: 269)
            .foregroundColor(.cheekBackgroundTeritory)
            .overlay(
                VStack(spacing: 0) {
                    Text("등록되지 않은 이메일 주소입니다.")
                        .title1(font: "SUIT", color: .cheekTextStrong, bold: true)
                        .padding(.bottom, 8)
                    
                    Text("이메일 주소를 다시 확인하거나\n이메일 주소 등록을 신청해 주세요.")
                        .caption1(font: "SUIT", color: .cheekTextAlternative, bold: true)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 32)
                    
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 5)
                            .frame(width: 149, height: 34)
                            .foregroundColor(.cheekTextAssitive)
                            .overlay(
                                Text("다시 입력")
                                    .caption1(font: "SUIT", color: .cheekTextStrong, bold: true)
                            )
                            .onTapGesture {
                                showPopup = false
                            }
                        
                        RoundedRectangle(cornerRadius: 5)
                            .frame(width: 149, height: 34)
                            .foregroundColor(.cheekTextAssitive)
                            .overlay(
                                Text("이메일 등록 신청")
                                    .caption1(font: "SUIT", color: .cheekTextStrong, bold: true)
                            )
                            .onTapGesture {
                                isDone = true
                                showPopup = false
                            }
                    }
                }
            )
        }
        .offset(x: 0, y: showPopup ? 0 : 269)
        .animation(.spring(), value: showPopup)
        .ignoresSafeArea()
    }
}

#Preview {
    VerifyEmailMentorView(socialProvider: .constant("Kakao"))
}
