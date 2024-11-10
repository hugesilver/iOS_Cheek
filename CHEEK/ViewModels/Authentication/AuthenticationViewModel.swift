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
    @Published var isRefreshTokenValid: Bool? = nil
    @Published var isConnected: Bool? = nil
    @Published var isProfileDone: Bool? = nil
    
    init() {
        checkRefreshTokenValid()
        checkServerConnection()
    }
    
    // 서버 연결상태 확인
    func checkServerConnection() {
        let url = URL(string: "\(ip)/token/access-token/issue")!
        
        // Header 세팅
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
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
            .eraseToAnyPublisher()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("checkServerConnection 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("checkServerConnection 함수 실행 중 요청 실패: \(error)")
                    DispatchQueue.main.async {
                        self.isConnected = false
                    }
                }
            }, receiveValue: { data in
                let dataString = String(data: data, encoding: .utf8)
                
                if dataString == "ok" {
                    DispatchQueue.main.async {
                        self.isConnected = true
                    }
                }
            })
            .store(in: &self.cancellables)
    }
    
    // 프로필 완료 확인
    func getProfileDone() {
        isProfileDone = UserDefaults.standard.bool(forKey: "profileDone")
    }
    
    // 리프레시 토큰 유효성 체크
    func checkRefreshTokenValid() {
        guard let _ = Keychain().read(key: "REFRESH_TOKEN"),
              let refreshTokenExpireTime = Keychain().read(key: "REFRESH_TOKEN_EXPIRE_TIME"),
              let refreshTokenExpireTimeToDate = Utils().convertTokenTime(timeString: refreshTokenExpireTime) else {
            isRefreshTokenValid = false
            return
        }
        
        isRefreshTokenValid = refreshTokenExpireTimeToDate >= Date()
        
        if !checkAccessTokenExpired() {
            self.reissueAccessToken()
        }
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
        }
        
        Keychain().delete(key: "MEMBER_TYPE")
        
        DispatchQueue.main.async {
            self.isRefreshTokenValid = false
            UserDefaults.standard.removeObject(forKey: "profileDone")
            self.isProfileDone = false
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
    }
}
