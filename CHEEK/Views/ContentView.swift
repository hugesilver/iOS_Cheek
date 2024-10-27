//
//  ContentView.swift
//  CHEEK
//
//  Created by 김태은 on 10/26/24.
//

import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth

struct ContentView: View {
    let appKeyKakao = Bundle.main.object(forInfoDictionaryKey: "KAKAO_APP_KEY") as! String
    
    @StateObject var authViewModel: AuthenticationViewModel = AuthenticationViewModel()
    
    init() {
        // Kakao SDK 초기화
        KakaoSDK.initSDK(appKey: appKeyKakao)
    }
    
    var body: some View {
        Group {
            if authViewModel.isInit {
                if authViewModel.isRefreshTokenValid {
                    MainView(authViewModel: authViewModel)
                } else {
                    WelcomeView(authViewModel: authViewModel)
                        .onOpenURL { url in
                            if (AuthApi.isKakaoTalkLoginUrl(url)) {
                                _ = AuthController.handleOpenUrl(url: url)
                            }
                        }
                }
            } else {
                VStack {
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.cheekBackgroundTeritory)
            }
        }
        .onChange(of: authViewModel.isRefreshTokenValid) { isValid in
            if authViewModel.isInit && !isValid {
                authViewModel.showAlert = true
                authViewModel.deleteTokensInKeychain()
            }
        }
        .onAppear {
            authViewModel.isRefreshTokenValid = authViewModel.checkRefreshTokenValid()
            authViewModel.isInit = true
        }
        .alert(isPresented: $authViewModel.showAlert) {
            Alert(title: Text("재로그인이 필요합니다."), dismissButton: .default(Text("확인")))
        }
    }
}

#Preview {
    ContentView()
}
