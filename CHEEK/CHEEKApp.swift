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
    @StateObject private var kakaoAuth = KakaoAuthViewModel()
    let appKeyKakao = Bundle.main.object(forInfoDictionaryKey: "KAKAO_APP_KEY") as! String
    
    init() {
        // Kakao SDK 초기화
        KakaoSDK.initSDK(appKey: appKeyKakao)
        kakaoAuth.checkToken() { isHasToken in}
    }
    
    var body: some Scene {
        WindowGroup {
            WelcomeView()
                .onOpenURL { url in
                    if (AuthApi.isKakaoTalkLoginUrl(url)) {
                        _ = AuthController.handleOpenUrl(url: url)
                    }
                }
        }
    }
}
