//
//  WelcomeView.swift
//  CHEEK
//
//  Created by 김태은 on 5/25/24.
//

import SwiftUI


struct WelcomeView: View {
    @State private var socialProvider: String = ""
    @State private var isLoginSuccess: Bool = false
    
    @StateObject private var kakaoAuthViewModel = KakaoAuthViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 로고와 슬로건
                VStack(spacing: 0) {
                    Image("LogoCheekColor")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 115)
                        .padding(.bottom, 5)
                    
                    Text("CHEEK!")
                        .font(.custom("SUIT", size: 40))
                        .fontWeight(.bold)
                    
                    Text("삐약이 주니어를 위한\n커리어 Q&A 플랫폼")
                        .font(.custom("SUIT", size: 14))
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, 65)
                
                // 로그인 버튼
                VStack(spacing: 8) {
                    Spacer()
                    
                    // 카카오 로그인
                    HStack(spacing: 11) {
                        Image("LogoKakao")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                        
                        Text("카카오 계정으로 로그인하기")
                            .label1(font: "SUIT", color: .kakaoLabel, bold: false)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 45)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.kakaoYellow)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.kakaoYellow, lineWidth: 1)
                    )
                    .onTapGesture {
                        socialProvider = "Kakao"
                        kakaoAuthViewModel.kakaoAuth() { success in
                            isLoginSuccess = success
                        }
                    }
                    
                    /*
                    // 구글 로그인
                    HStack(spacing: 11) {
                        Image("LogoGoogle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                        Text("Google 계정으로 로그인하기")
                            .label1(font: "SUIT", color: .cheekTextStrong, bold: false)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 45)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.cheekTextAlternative, lineWidth: 1)
                    )
                    .onTapGesture {
                     
                    }
                     */
                }
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 44)
            .background(.cheekBackgroundTeritory)
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $isLoginSuccess, destination: {
                SelectMentorMenteeView(socialProvider: $socialProvider)
            })
        }
    }
}

#Preview {
    WelcomeView()
}
