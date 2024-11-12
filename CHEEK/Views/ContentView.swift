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
    
    @ObservedObject var stateViewModel: StateViewModel
    
    @State private var showAlert: Bool = false
    @State private var alertType: AlertType = .refreshToken
    
    var body: some View {
        ZStack {
            if stateViewModel.isInit && stateViewModel.isProfileDone != nil {
                if stateViewModel.isRefreshTokenValid == true && stateViewModel.isProfileDone! {
                    MainView(stateViewModel: stateViewModel)
                } else {
                    WelcomeView(stateViewModel: stateViewModel)
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
                    onTap: {stateViewModel.logOut()}
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            stateViewModel.isInit = true
            stateViewModel.getProfileDone()
        }
        .onReceive(stateViewModel.$isConnected) { isConnected in
            if isConnected == false {
                alertType = .connection
                showAlert = true
            }
        }
        .onChange(of: stateViewModel.isRefreshTokenValid) { isValid in
            if stateViewModel.isInit && isValid == false {
                alertType = .refreshToken
                showAlert = true
                stateViewModel.logOut()
            }
        }
    }
}

#Preview {
    ContentView(stateViewModel: StateViewModel())
}
