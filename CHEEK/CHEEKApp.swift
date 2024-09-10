//
//  CHEEKApp.swift
//  CHEEK
//
//  Created by 김태은 on 5/24/24.
//

import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth

@main
struct CHEEKApp: App {
    let appKeyKakao = Bundle.main.object(forInfoDictionaryKey: "KAKAO_APP_KEY") as! String
    
    init() {
        // Kakao SDK 초기화
        KakaoSDK.initSDK(appKey: appKeyKakao)
        AuthenticationViewModel().autoSignIn() { success in
            print(success)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            WelcomeView()
                .onOpenURL { url in
                    if (AuthApi.isKakaoTalkLoginUrl(url)) {
                        _ = AuthController.handleOpenUrl(url: url)
                    }
                }
                .onAppear {
                    
                }
        }
    }
}
