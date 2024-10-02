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
    
    @State private var isLoading: Bool = false
    @State private var showAlert: Bool = false
    
    @StateObject var profileViewModel = ProfileViewModel()
    @StateObject private var kakaoAuthViewModel = KakaoAuthViewModel()
    
    var body: some View {
        NavigationStack {
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
                            kakaoAuthViewModel.kakaoAuth() { isSet in
                                guard let isSet else {
                                    self.showAlert = true
                                    return
                                }
                                
                                if isSet {
                                    profileViewModel.getProfile()
                                }
                                
                                isSetProfile = isSet
                                isLoginSuccess = true
                                
                                isLoading = false
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
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                if isLoading {
                    LoadingView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.cheekBackgroundTeritory)
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $isLoginSuccess, destination: {
                /*
                if isSetProfile {
                    MainView(profileViewModel: profileViewModel)
                } else {
                    MentorMenteeView()
                }
                 */
                
                MentorMenteeView()
            })
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("오류"),
                message: Text("인증 확인 중 발생하였습니다."),
                dismissButton: .default(
                    Text("확인"),
                    action: {
                        isLoading = false
                    }
                )
            )
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
