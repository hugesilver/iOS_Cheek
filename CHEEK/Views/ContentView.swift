//
//  ContentView.swift
//  CHEEK
//
//  Created by 김태은 on 10/26/24.
//

import SwiftUI
import KakaoSDKAuth

struct ContentView: View {
    enum AlertType { case refreshToken, connection }
    
    @ObservedObject var authViewModel: AuthenticationViewModel
    
    @State private var showAlert: Bool = false
    @State private var alertType: AlertType = .refreshToken
    
    var body: some View {
        ZStack {
            if authViewModel.isProfileDone != nil {
                if authViewModel.isRefreshTokenValid == true && authViewModel.isProfileDone! {
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
                Color(.cheekBackgroundTeritory)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            if showAlert && alertType == .refreshToken {
                CustomAlert(
                    showAlert: $showAlert,
                    title: "재로그인이 필요합니다.",
                    buttonText: "확인",
                    onTap: {}
                )
            }
            
            if showAlert && alertType == .connection {
                CustomAlert(
                    showAlert: $showAlert,
                    title: "서버에 연결을 할 수 없습니다.",
                    buttonText: "확인",
                    onTap: {authViewModel.logOut()}
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onReceive(authViewModel.$isConnected) { isConnected in
            if isConnected == false {
                alertType = .connection
                showAlert = true
            }
        }
        .onChange(of: authViewModel.isRefreshTokenValid) { isValid in
            if isValid == false {
                alertType = .refreshToken
                showAlert = true
                authViewModel.logOut()
            }
        }
    }
}

#Preview {
    ContentView(authViewModel: AuthenticationViewModel())
}
