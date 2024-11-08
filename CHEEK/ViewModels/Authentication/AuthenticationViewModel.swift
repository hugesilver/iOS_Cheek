//
//  AuthenticationViewModel.swift
//  CHEEK
//
//  Created by 김태은 on 9/9/24.
//

import Foundation
import Combine

class AuthenticationViewModel: ObservableObject {
    private let ip = Bundle.main.object(forInfoDictionaryKey: "SERVER_IP") as! String
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isInit: Bool = false
    @Published var showAlert: Bool = false
    @Published var isRefreshTokenValid: Bool = false
    
    // 리프레시 토큰 유효성 체크
    func checkRefreshTokenValid() -> Bool {
        guard let _ = Keychain().read(key: "REFRESH_TOKEN"),
              let refreshTokenExpireTime = Keychain().read(key: "REFRESH_TOKEN_EXPIRE_TIME"),
              let refreshTokenExpireTimeToDate = Utils().convertTokenTime(timeString: refreshTokenExpireTime) else {
            return false
        }
        
        return refreshTokenExpireTimeToDate >= Date()
    }
    
    // 액세스 토큰 미유효 체크
    func checkAccessTokenExpired() -> Bool {
        guard let _ = Keychain().read(key: "ACCESS_TOKEN"),
              let accessTokenExpireTime = Keychain().read(key: "ACCESS_TOKEN_EXPIRE_TIME"),
              let accessTokenExpireTimeToDate = Utils().convertTokenTime(timeString: accessTokenExpireTime) else {
            return true
        }
        
        return accessTokenExpireTimeToDate <= Date()
    }
    
    // 로그아웃
    func logOut() {
        Keychain().delete(key: "MEMBER_ID")
        Keychain().delete(key: "ACCESS_TOKEN")
        Keychain().delete(key: "ACCESS_TOKEN_EXPIRE_TIME")
        Keychain().delete(key: "REFRESH_TOKEN")
        Keychain().delete(key: "REFRESH_TOKEN_EXPIRE_TIME")
        
        if let socialMedia: String = Keychain().read(key: "MEMBER_TYPE") {
            if socialMedia == "KAKAO" {
                KakaoAuthViewModel().logout()
            }
            
            Keychain().delete(key: "MEMBER_TYPE")
        }
    }
    
    func serverLogout() {
        let url = URL(string: "\(ip)/member/logout")!
        
        // Header 세팅
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        CombinePublishers().urlSession(req: request)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("logout 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("logout 함수 실행 중 요청 실패: \(error)")
                }
            }, receiveValue: { data in
                let dataString = String(data: data, encoding: .utf8)
                
                if dataString == "ok" {
                    
                }
            })
            .store(in: &self.cancellables)
        
        self.logOut()
        
        DispatchQueue.main.async {
            self.isRefreshTokenValid = false
        }
    }
}
