//
//  SetProfileMentorView.swift
//  CHEEK
//
//  Created by 김태은 on 6/5/24.
//

import SwiftUI

struct RegisterDomainView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = VerifyEmailMentorViewModel()
    
    @State private var isMentor: Bool = false
    
    @State private var email: String = ""
    @State var statusEmail: TextFieldForm.statuses = .normal
    @State private var isEmailValidated: Bool = false
    @FocusState var isEmailFocused: Bool
    @State private var isLoading: Bool = false
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    @State private var isSent: Bool = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var time: Int = 3
    @State private var timeRunning: Bool = false
    
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
                    
                    Text("사내 이메일 등록을 신청합니다.")
                        .headline1(font: "SUIT", color: .cheekTextNormal, bold: true)
                        .padding(.top, 24)
                    
                    Text("관리자 확인 후 멘토 회원으로 전환됩니다.")
                        .label1(font: "SUIT", color: .cheekTextAlternative, bold: true)
                        .padding(.top, 4)
                    
                    // 이메일 입력칸
                    TextFieldForm(name: "이메일", placeholder: "예 > cheek@cheek.com", keyboardType: .emailAddress, text: $email, information: "", status: $statusEmail, isFocused: $isEmailFocused)
                        .onChange(of: email) { _ in
                            isEmailValidated = viewModel.validateEmail(email: email)
                        }
                        .padding(.top, 16)
                    
                    Spacer()
                    
                    // 인증번호 받기
                    if isEmailValidated {
                        ButtonActive(text: "등록 신청하기")
                            .onTapGesture {
                                hideKeyboard()
                                
                                if !isLoading {
                                    isLoading = true
                                    if viewModel.validateEmail(email: email) {
                                        viewModel.registerDomain(email: email) { response in
                                            if response {
                                                isLoading = false
                                                
                                                isSent = true
                                                timeRunning = true
                                                isLoading = false
                                                
                                            } else {
                                                alertMessage = "오류가 발생하였습니다.\n다시 시도해주세요."
                                                showAlert = true
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
                        ButtonDisabled(text: "등록 신청하기")
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, isEmailFocused ? 24 : 31)
                .background(.cheekBackgroundTeritory)
                
                if isSent {
                    EmailregisterDoneView(time: time)
                        .onReceive(timer) { _ in
                            if timeRunning {
                                if time > 0 {
                                    time -= 1
                                } else {
                                    isDone = true
                                }
                            }
                        }
                }
                
                if isLoading {
                    LoadingView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $isDone, destination: {
            SetProfileView(isMentor: $isMentor)
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

struct EmailregisterDoneView: View {
    @State var time: Int
    
    var body: some View {
        VStack(spacing: 16) {
            Image("IconChecked")
                .resizable()
                .frame(width: 160, height: 160)
            
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
    RegisterDomainView()
}
