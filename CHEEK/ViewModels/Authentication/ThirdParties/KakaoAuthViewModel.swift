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

class KakaoAuthViewModel: ObservableObject {
    var cancellables = Set<AnyCancellable>()
    
    // 토큰 확인
    func checkToken(completion: @escaping (Bool) -> Void) {
        if (AuthApi.hasToken()) {
            completion(true)
        } else {
            print("카카오 토큰 유효하지 않음")
            completion(false)
        }
    }
    
    // 카카오 로그인
    func kakaoAuth(completion: @escaping (Bool?) -> Void) {
        if (UserApi.isKakaoTalkLoginAvailable()) {
            UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                if let error = error {
                    print("카카오톡 앱을 통하여 로그인 중 오류: \(error)")
                    completion(nil)
                }
                
                if oauthToken != nil {
                    print("카카오톡 앱을 통하여 로그인 성공: \(String(describing: oauthToken))")
                    self.sendToken(token: oauthToken!) { isSet in
                        completion(isSet)
                    }
                    return
                }
            }
        } else {
            UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                if let error = error {
                    print("카카오톡 웹사이트를 통하여 로그인 중 오류: \(error)")
                    completion(nil)
                }
                
                if oauthToken != nil {
                    print("카카오톡 웹사이트를 통하여 로그인 성공: \(String(describing: oauthToken))")
                    self.sendToken(token: oauthToken!) { isSet in
                        completion(isSet)
                    }
                    return
                }
            }
        }
    }
    
    // 토큰 저장
    func saveTokenInKeychain(token: OAuthToken) {
        Keychain().create(key: "ACCESS_TOKEN", value: token.accessToken)
        Keychain().create(key: "REFRESH_TOKEN", value: token.refreshToken)
    }
    
    // 토큰 전송
    func sendToken(token: OAuthToken, completion: @escaping (Bool?) -> Void) {
        print("전송 시도 중")
        let ip = Bundle.main.object(forInfoDictionaryKey: "SERVER_IP") as! String
        let url = URL(string: "\(ip)/member/login")!
        
        // Header 세팅
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        // Body 세팅
        let bodyData: AuthTokenModel = AuthTokenModel(
            accessToken: token.accessToken,
            refreshToken: token.refreshToken,
            accessTokenExpireTime: formatter.string(from: token.expiredAt),
            refreshTokenExpireTime: formatter.string(from: token.refreshTokenExpiredAt)
        )!
        
        do {
            request.httpBody = try JSONEncoder().encode(bodyData)
        } catch {
            print("카카오 토큰 JSON 변환 중 오류: \(error)")
            completion(nil)
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap() { data, response in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("sendToken 응답 코드: \(response)")
                    throw URLError(.badServerResponse)
                }
                
                if let dataString = String(data: data, encoding: .utf8) {
                    return dataString
                } else {
                    print("data를 String으로 변환 중 오류 발생")
                    throw URLError(.cannotDecodeContentData)
                }
            }
            .retry(1)
            .eraseToAnyPublisher()
            .sink(receiveCompletion: { isCompletion in
                switch isCompletion {
                case .finished:
                    print("sendToken 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("sendToken 함수 실행 중 요청 실패: \(error)")
                    completion(nil)
                }
            }, receiveValue: { data in
                print("카카오 토큰 전송 응답: \(data)")
                DispatchQueue.main.async {
                    if data == "true" {
                        Keychain().create(key: "SOCIAL_MEDIA", value: "KAKAO")
                        self.saveTokenInKeychain(token: token)
                        completion(true)
                    } else {
                        print("카카오 토큰 전송 응답 데이터를 문자열로 변환하는 데 실패했습니다.")
                        completion(nil)
                        return
                    }
                }
            })
            .store(in: &cancellables)
    }
    
    // 카카오 이메일 확인
    func getEmail(completion: @escaping (String?) -> Void) {
        UserApi.shared.me() {(user, error) in
            if let error = error {
                print("카카오 계정 이메일 확인 중 오류: \(error)")
                completion(nil)
            }
            else {
                completion(user?.kakaoAccount?.email)
            }
        }
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
