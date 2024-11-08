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
        
        if !checkAccessTokenExpired() {
            self.reissueAccessToken()
        }
        
        return refreshTokenExpireTimeToDate >= Date()
    }
    
    // 액세스 토큰 유효 체크
    func checkAccessTokenExpired() -> Bool {
        guard let _ = Keychain().read(key: "ACCESS_TOKEN"),
              let accessTokenExpireTime = Keychain().read(key: "ACCESS_TOKEN_EXPIRE_TIME"),
              let accessTokenExpireTimeToDate = Utils().convertTokenTime(timeString: accessTokenExpireTime) else {
            return false
        }
        
        return accessTokenExpireTimeToDate >= Date()
    }
    
    // 액세스 토큰 재발급
    func reissueAccessToken() {
        if !self.checkRefreshTokenValid() {
            print("REFRESH_TOKEN이 유효하지 않음")
            return
        }
        
        guard let refreshToken = Keychain().read(key: "REFRESH_TOKEN"),
              let _ = Keychain().read(key: "ACCESS_TOKEN"),
              let accessTokenExpireTime = Keychain().read(key: "ACCESS_TOKEN_EXPIRE_TIME"),
              let _ = Utils().convertTokenTime(timeString: accessTokenExpireTime) else {
            print("토큰 정보가 유효하지 않음")
            return
        }
        
        let url = URL(string: "\(ip)/token/access-token/issue")!
        
        // Header 세팅
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(refreshToken)", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap() { data, response in
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                    print("응답 코드: \(response)")
                }
                
                // 디버깅
                if let dataString = String(data: data, encoding: .utf8) {
                    print(dataString)
                }
                
                return data
            }
            .retry(1)
            .eraseToAnyPublisher()
            .decode(type: AccessTokenModel.self, decoder: JSONDecoder())
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("reissueAccessToken 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("reissueAccessToken 함수 실행 중 요청 실패: \(error)")
                }
            }, receiveValue: { data in
                Keychain().create(key: "ACCESS_TOKEN", value: data.accessToken)
                Keychain().create(key: "ACCESS_TOKEN_EXPIRE_TIME", value: data.accessTokenExpireTime)
                    
            })
            .store(in: &self.cancellables)
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
                    print("로그아웃 완료")
                }
            })
            .store(in: &self.cancellables)
        
        self.logOut()
        
        DispatchQueue.main.async {
            self.isRefreshTokenValid = false
        }
    }
}
