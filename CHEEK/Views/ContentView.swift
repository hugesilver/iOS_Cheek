//
//  ContentView.swift
//  CHEEK
//
//  Created by 김태은 on 10/26/24.
//

import SwiftUI
import KakaoSDKAuth

struct ContentView: View {
    @ObservedObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        Group {
            if authViewModel.isInit && authViewModel.isProfileDone != nil {
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
                VStack {
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.cheekBackgroundTeritory)
            }
        }
        .onAppear {
            authViewModel.isInit = true
            authViewModel.getProfileDone()
        }
    }
}

#Preview {
    ContentView(authViewModel: AuthenticationViewModel())
}
