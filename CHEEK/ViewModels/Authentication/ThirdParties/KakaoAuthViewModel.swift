//
//  AuthKakaoViewModel.swift
//  CHEEK
//
//  Created by 김태은 on 5/28/24.
//

import Foundation

import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser
import Combine
import UIKit

class KakaoAuthViewModel: ObservableObject {
    private let ip = Bundle.main.object(forInfoDictionaryKey: "SERVER_IP") as! String
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isComplete: Bool? = nil
    @Published var profileComplete: Bool? = nil
    
    // 카카오 로그인
    func signIn() {
        if (UserApi.isKakaoTalkLoginAvailable()) {
            UserApi.shared.loginWithKakaoTalk { (oauthToken, error) in
                if let error = error {
                    print("카카오톡 앱을 통하여 로그인 중 오류: \(error)")
                    self.isComplete = false
                }
                
                if oauthToken != nil {
                    print("카카오톡 앱을 통하여 로그인 성공: \(String(describing: oauthToken))")
                    
                    self.oAuthLogin(token: oauthToken!.accessToken)
                    
                    // 액세스 토큰 복사 테스트용 코드
                    UIPasteboard.general.string = oauthToken?.accessToken
                    return
                }
            }
        } else {
            UserApi.shared.loginWithKakaoAccount { (oauthToken, error) in
                if let error = error {
                    print("카카오톡 웹사이트를 통하여 로그인 중 오류: \(error)")
                    self.isComplete = false
                }
                
                if oauthToken != nil {
                    print("카카오톡 웹사이트를 통하여 로그인 성공: \(String(describing: oauthToken))")
                    
                    self.oAuthLogin(token: oauthToken!.accessToken)
                    
                    // 액세스 토큰 복사 테스트용 코드
                    UIPasteboard.general.string = oauthToken?.accessToken
                    return
                }
            }
        }
    }
    
    // 서버에 카카오 토큰 전송 및 토큰 발급
    func oAuthLogin(token: String) {
        print("카카오 로그인 시도")
        
        let url = URL(string: "\(ip)/oauth/login")!
        
        // Header 세팅
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Body 세팅
        let bodyData: [String: Any] = [
            "memberType": "KAKAO"
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: bodyData, options: [])
        } catch {
            print("OAuth Login JSON 변환 중 오류: \(error)")
            self.isComplete = false
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: request)
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
            .decode(type: OAuthLoginResponseModel.self, decoder: JSONDecoder())
            .sink(receiveCompletion: { isComplete in
                switch isComplete {
                case .finished:
                    print("oauthLogin 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("oauthLogin 함수 실행 중 요청 실패: \(error)")
                    DispatchQueue.main.async {
                        self.isComplete = false
                    }
                }
            }, receiveValue: { data in
                Keychain().create(key: "MEMBER_TYPE", value: "KAKAO")
                Keychain().create(key: "MEMBER_ID", value: "\(data.memberId)")
                Keychain().create(key: "ACCESS_TOKEN", value: data.accessToken)
                Keychain().create(key: "ACCESS_TOKEN_EXPIRE_TIME", value: data.accessTokenExpireTime)
                Keychain().create(key: "REFRESH_TOKEN", value: data.refreshToken)
                Keychain().create(key: "REFRESH_TOKEN_EXPIRE_TIME", value: data.refreshTokenExpireTime)
                
                DispatchQueue.main.async {
                    self.profileComplete = data.profileComplete
                    self.isComplete = true
                }
            })
            .store(in: &cancellables)
    }
    
    // 카카오 계정 로그아웃
    func logout() {
        UserApi.shared.logout {(error) in
            if let error = error {
                print("카카오 계정 로그아웃 중 오류: \(error)")
            }
            else {
                print("카카오 로그아웃 성공")
            }
        }
    }
}
