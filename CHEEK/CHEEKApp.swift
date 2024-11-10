//
//  CHEEKApp.swift
//  CHEEK
//
//  Created by 김태은 on 5/24/24.
//

import SwiftUI
import KakaoSDKCommon

@main
struct CHEEKApp: App {
    let appKeyKakao = Bundle.main.object(forInfoDictionaryKey: "KAKAO_APP_KEY") as! String
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var authViewModel: AuthenticationViewModel = AuthenticationViewModel()
    
    init() {
        // Kakao SDK 초기화
        KakaoSDK.initSDK(appKey: appKeyKakao)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(authViewModel: authViewModel)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    authViewModel.checkServerConnection()
                    authViewModel.checkRefreshTokenValid()
                }
        }
    }
}
