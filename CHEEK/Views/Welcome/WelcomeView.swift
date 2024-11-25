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
    
    @State var showTermsOfService: Bool = true
    
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
                
                if showTermsOfService {
                    AggrementView(
                        onTapDone: { showTermsOfService = false }
                    )
                }
                
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

// 소셜 로그인 버튼
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

// 약관 동의
struct AggrementView: View {
    var onTapDone: () -> Void
    
    @State private var isServiceAgreed: Bool = false
    @State private var showServiceAgreement: Bool = false
    
    @State private var isPrivacyAgreed: Bool = false
    @State private var showPrivacyAgreement: Bool = false
    
    var body: some View {
        ZStack {
            Color(red: 0, green: 0, blue: 0).opacity(0.4)
            
            Group {
                VStack(spacing: 0) {
                    Text("CHEEK! 약관동의")
                        .headline1(font: "SUIT", color: .cheekTextNormal, bold: true)
                        .padding(.bottom, 24)
                    
                    VStack(spacing: 16) {
                        // 서비스 이용약관 동의
                        HStack(spacing: 8) {
                            Button(action: {
                                isServiceAgreed.toggle()
                            }) {
                                if isServiceAgreed {
                                    Circle()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(.cheekMainNormal)
                                        .overlay(
                                            Image("IconCheck")
                                                .resizable()
                                                .frame(width: 16, height: 16)
                                                .foregroundColor(.cheekTextNormal)
                                        )
                                } else {
                                    Circle()
                                        .fill(.cheekTextAssitive)
                                        .frame(width: 24, height: 24)
                                }
                            }
                            
                            Text("(필수) 서비스 이용약관 동의")
                                .body1(font: "SUIT", color: .cheekTextNormal, bold: false)
                            
                            Spacer()
                            
                            Button(action: {
                                showServiceAgreement.toggle()
                            }) {
                                Text("보기")
                                    .body1(font: "SUIT", color: .cheekTextAlternative, bold: true)
                            }
                        }
                        
                        // 개인정보 수집 및 이용 동의
                        HStack(spacing: 8) {
                            Button(action: {
                                isPrivacyAgreed.toggle()
                            }) {
                                if isPrivacyAgreed {
                                    Circle()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(.cheekMainNormal)
                                        .overlay(
                                            Image("IconCheck")
                                                .resizable()
                                                .frame(width: 16, height: 16)
                                                .foregroundColor(.cheekTextNormal)
                                        )
                                } else {
                                    Circle()
                                        .fill(.cheekTextAssitive)
                                        .frame(width: 24, height: 24)
                                }
                            }
                            
                            Text("(필수) 개인정보 수집 및 이용 동의")
                                .body1(font: "SUIT", color: .cheekTextNormal, bold: false)
                            
                            Spacer()
                            
                            Button(action: {
                                showPrivacyAgreement.toggle()
                            }) {
                                Text("보기")
                                    .body1(font: "SUIT", color: .cheekTextAlternative, bold: true)
                            }
                        }
                    }
                    .padding(.bottom, 32)
                    
                    if isServiceAgreed && isPrivacyAgreed {
                        Button(action: {
                            onTapDone()
                        }) {
                            ButtonActive(text: "확인")
                        }
                    } else {
                        ButtonDisabled(text: "확인")
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 32)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.cheekWhite)
                )
            }
            .padding(16)
        }
        .ignoresSafeArea()
        .sheet(isPresented: $showServiceAgreement) {
            WebView(url: "https://malleable-can-825.notion.site/Cheek-ed7d2691b18948a2bf4fbeb0c22dff36?pvs=4")
                .presentationDragIndicator(.hidden)
                .presentationDetents([.fraction(0.9)])
        }
        .sheet(isPresented: $showPrivacyAgreement) {
            WebView(url: "https://malleable-can-825.notion.site/cf2b03b6bed24dbebc866fa3cf0a1c6b?pvs=4")
                .presentationDragIndicator(.hidden)
                .presentationDetents([.fraction(0.9)])
        }
    }
}

#Preview {
    WelcomeView(authViewModel: AuthenticationViewModel())
}
