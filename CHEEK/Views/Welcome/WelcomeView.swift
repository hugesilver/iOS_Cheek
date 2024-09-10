//
//  WelcomeView.swift
//  CHEEK
//
//  Created by 김태은 on 5/25/24.
//

import SwiftUI


struct WelcomeView: View {
    @State private var isLoginSuccess: Bool = false
    @State private var isSetProfile: Bool = false
    
    @StateObject private var kakaoAuthViewModel = KakaoAuthViewModel()
    
    var body: some View {
        NavigationStack {
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
                        kakaoAuthViewModel.kakaoAuth() { isSet in
                            isSetProfile = isSet
                            isLoginSuccess = true
                        }
                    }
                    
                    /*
                    // 애플 로그인
                    WelcomeViewSocialButton(
                        text: "애플로 시작하기",
                        textColor: .appleWhite,
                        isSystemImage: true,
                        image: "apple.logo",
                        systemImageColor: .appleWhite,
                        bgColor: .appleBlack
                    )
                    .onTapGesture {
                    }
                     */
                }
                .padding(.bottom, 31)
            }
            .padding(.horizontal, 16)
            .background(.cheekBackgroundTeritory)
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $isLoginSuccess, destination: {
                if isSetProfile {
                    MainView()
                } else {
                    MentorMenteeView()
                }
            })
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
    WelcomeView()
}
