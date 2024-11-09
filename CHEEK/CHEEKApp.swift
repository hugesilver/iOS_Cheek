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
    enum AlertType { case refreshToken, connection }
    
    let appKeyKakao = Bundle.main.object(forInfoDictionaryKey: "KAKAO_APP_KEY") as! String
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var authViewModel: AuthenticationViewModel = AuthenticationViewModel()
    
    @State private var showAlert: Bool = false
    @State private var alertType: AlertType = .refreshToken
    
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
                .onReceive(authViewModel.$isConnected) { isConnected in
                    if isConnected == false {
                        alertType = .connection
                        showAlert = true
                    }
                }
                .onReceive(authViewModel.$isRefreshTokenValid) { isValid in
                    if authViewModel.isInit && isValid == false {
                        alertType = .refreshToken
                        showAlert = true
                        authViewModel.logOut()
                    }
                }
                .alert(isPresented: $showAlert) {
                    switch alertType {
                    case .refreshToken:
                        Alert(title: Text("재로그인이 필요합니다."), dismissButton: .default(Text("확인")))
                    case .connection:
                        Alert(title: Text("서버에 연결을 할 수 없습니다."), dismissButton: .default(Text("확인"), action: {
                            authViewModel.logOut()
                        }))
                    }
                }
        }
    }
}
