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

class KakaoAuthViewModel: ObservableObject {
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
    func kakaoAuth(completion: @escaping (Bool) -> Void) {
        if (UserApi.isKakaoTalkLoginAvailable()) {
            UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                if let error = error {
                    print("카카오톡 앱을 통하여 로그인 중 오류: \(error)")
                    completion(false)
                }
                
                if oauthToken != nil{
                    print("카카오톡 앱을 통하여 로그인 성공: \(String(describing: oauthToken))")
                    self.sendToken(token: oauthToken!) { success in
                        completion(success)
                    }
                    return
                }
            }
        } else {
            UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                if let error = error {
                    print("카카오톡 웹사이트를 통하여 로그인 중 오류: \(error)")
                    completion(false)
                }
                
                if oauthToken != nil{
                    print("카카오톡 웹사이트를 통하여 로그인 성공: \(String(describing: oauthToken))")
                    self.sendToken(token: oauthToken!) { success in
                        completion(success)
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
    func sendToken(token: OAuthToken, completion: @escaping (Bool) -> Void) {
        print("전송 시도 중")
        let ip = Bundle.main.object(forInfoDictionaryKey: "SERVER_IP") as! String
        let url = URL(string: "http://\(ip)/member/login")!
        
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
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("카카오 토큰 전송 중 오류: \(error)")
                return
            } else if let data = data {
                if let dataString = String(data: data, encoding: .utf8) {
                    let response = (dataString as NSString).boolValue
                    print("카카오 토큰 전송 응답: \(response)")
                    Keychain().create(key: "SOCIAL_MEDIA", value: "KAKAO")
                    self.saveTokenInKeychain(token: token)
                    completion(response)
                } else {
                    print("카카오 토큰 전송 응답 데이터를 문자열로 변환하는 데 실패했습니다.")
                    return
                }
            }
        }
        
        task.resume()
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
