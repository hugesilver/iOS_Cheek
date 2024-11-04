//
//  SetProfileMentorView.swift
//  CHEEK
//
//  Created by 김태은 on 6/5/24.
//

import SwiftUI

struct RegisterDomainView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var authViewModel: AuthenticationViewModel
    @Binding var navPath: NavigationPath
    var isMentor: Bool
    
    @StateObject private var viewModel = RegisterDomainViewModel()
    
    // 이메일 폼
    @State private var email: String = ""
    @State var statusEmail: TextFieldForm.statuses = .normal
    @FocusState var isEmailFocused: Bool
    @State private var isEmailValidated: Bool = false
    
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
                    isReqired: true,
                    text: $email,
                    information: .constant(""),
                    status: $statusEmail,
                    isFocused: $isEmailFocused)
                .onChange(of: email) { _ in
                    isEmailValidated = viewModel.validateEmail(email: email)
                }
                .padding(.top, 16)
                
                Spacer()
                
                // 인증번호 받기
                if isEmailValidated {
                    ButtonActive(text: "등록 신청하기")
                        .onTapGesture {
                            registerDomain()
                        }
                } else {
                    ButtonDisabled(text: "등록 신청하기")
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, isEmailFocused ? 24 : 31)
            .background(.cheekBackgroundTeritory)
            
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
        .navigationDestination(isPresented: $viewModel.isDone, destination: {
            SetProfileView(authViewModel: authViewModel, navPath: $navPath, isMentor: isMentor)
        })
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("오류"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("확인")))
        }
        .onDisappear {
            // 타이머 종료
            viewModel.cancelTimer()
        }
    }
    
    // 도메인 전송
    func registerDomain() {
        Utils().hideKeyboard()
        
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
    RegisterDomainView(authViewModel: AuthenticationViewModel(), navPath: .constant(NavigationPath()), isMentor: true)
}
