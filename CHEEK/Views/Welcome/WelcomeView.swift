//
//  WelcomeView.swift
//  CHEEK
//
//  Created by 김태은 on 5/25/24.
//

import SwiftUI

struct WelcomeView: View {
    @ObservedObject var authViewModel: AuthenticationViewModel
    
    @State private var navPath: NavigationPath = NavigationPath()
    
    @StateObject private var kakaoAuthViewModel: KakaoAuthViewModel = KakaoAuthViewModel()
    @StateObject private var appleAuthViewModel: AppleAuthViewModel = AppleAuthViewModel()
    
    @State var isMentor: Bool?
    
    @State private var isLoading: Bool = false
    @State private var showAlert: Bool = false
    
    var body: some View {
        NavigationStack(path: $navPath) {
            ZStack {
                VStack(spacing: 0) {
                    // 로고와 슬로건
                    VStack(spacing: 24) {
                        VStack(spacing: 16) {
                            Image("LogoCheekColor")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 104)
                            
                            Image("LogoCheekLetters")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 132)
                        }
                        
                        Text("삐약이 주니어를 위한\n커리어 Q&A 플랫폼")
                            .title1(font: "SUIT", color: .cheekBlack, bold: true)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 156)
                    
                    Spacer()
                    
                    // 로그인 버튼
                    VStack(spacing: 16) {
                        // 카카오 로그인
                        WelcomeViewSocialButton(
                            text: "카카오로 시작하기",
                            textColor: .kakaoLabel,
                            isSystemImage: false,
                            image: "LogoKakao",
                            bgColor: .kakaoYellow
                        )
                        .onTapGesture {
                            isLoading = true
                            kakaoAuthViewModel.signIn()
                        }
                        
                        // 애플 로그인
                        WelcomeViewSocialButton(
                            text: "Apple로 시작하기",
                            textColor: .appleWhite,
                            isSystemImage: true,
                            image: "apple.logo",
                            systemImageColor: .appleWhite,
                            bgColor: .appleBlack
                        )
                        .onTapGesture {
                            appleAuthViewModel.signIn()
                        }
                    }
                    .padding(.bottom, 31)
                }
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                if isLoading {
                    LoadingView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.cheekBackgroundTeritory)
            .navigationDestination(for: String.self) { path in
                switch path {
                case "MentorMenteeView":
                    MentorMenteeView(navPath: $navPath, isMentor: $isMentor)
                    
                case "VerifyMentorView":
                    VerifyMentorView(navPath: $navPath)
                    
                case "SetProfileView":
                    SetProfileView(authViewModel: authViewModel, navPath: $navPath, isMentor: $isMentor)
                    
                default: EmptyView()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onReceive(kakaoAuthViewModel.$isComplete) { isComplete in
            if isLoading && isComplete == false {
                showAlert = true
            }
        }
        .onReceive(appleAuthViewModel.$isComplete) { isComplete in
            if isLoading && isComplete == false {
                showAlert = true
            }
        }
        .onChange(of: kakaoAuthViewModel.profileComplete) { profileComplete in
            isProfileComplete(profileComplete: profileComplete)
        }
        .onChange(of: appleAuthViewModel.profileComplete) { profileComplete in
            isProfileComplete(profileComplete: profileComplete)
        }
        .onAppear {
            isLoading = false
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("인증에 실패했습니다."),
                dismissButton: .default(
                    Text("확인"),
                    action: {
                        isLoading = false
                    }
                )
            )
        }
    }
    
    func isProfileComplete(profileComplete: Bool?) {
        if profileComplete != nil {
            if profileComplete! {
                // 메인 페이지로 변경
                DispatchQueue.main.async {
                    authViewModel.isRefreshTokenValid = true
                    authViewModel.isProfileDone = true
                    UserDefaults.standard.set(true, forKey: "profileDone")
                }
            } else {
                navPath.append("MentorMenteeView")
            }
        }
    }
}

struct WelcomeViewSocialButton: View {
    var text: String
    var textColor: Color
    var isSystemImage: Bool
    var image: String
    var systemImageColor: Color?
    var bgColor: Color
    
    var body: some View {
        HStack(spacing: 8) {
            if isSystemImage {
                Image(systemName: image)
                    .resizable()
                    .foregroundColor(systemImageColor)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18)
            } else {
                Image(image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20)
            }
            
            Text(text)
                .label1(font: "SUIT", color: textColor, bold: true)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(bgColor)
        )
    }
}

#Preview {
    WelcomeView(authViewModel: AuthenticationViewModel())
}
