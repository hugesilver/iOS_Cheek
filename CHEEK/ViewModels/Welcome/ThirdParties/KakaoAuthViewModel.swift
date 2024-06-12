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
            UserApi.shared.accessTokenInfo { (accessTokenInfo, error) in
                if let error = error {
                    if let sdkError = error as? SdkError, sdkError.isInvalidTokenError() == true  {
                        print("카카오 토큰 유효하지 않음(sdk error)")
                        completion(false)
                    }
                    else {
                        //기타 에러
                        print("checkToken 함수 실행 중 오류")
                        completion(false)
                    }
                }
                else {
                    //토큰 유효성 체크 성공(필요 시 토큰 갱신됨)
                    print("카카오 토큰 유효: \(String(describing: accessTokenInfo))")
                    completion(true)
                }
            }
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
    
    // 토큰 전송
    func sendToken(token: OAuthToken, completion: @escaping (Bool) -> Void) {
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
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: bodyData)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("카카오 토큰 전송 중 오류: \(error)")
                completion(false)
            } else if let data = data {
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJSON = responseJSON as? Bool {
                    print("카카오 토큰 전송 응답 후 프로필 설정 여부: \(responseJSON)")
                    completion(responseJSON)
                }
            }
        }
        
        task.resume()
    }
    
    // 프로필 조회
    func getProfileFromKakao(token: OAuthToken, completion: @escaping (ProfileModel?) -> Void) {
        let ip = Bundle.main.object(forInfoDictionaryKey: "SERVER_IP") as! String
        let url = URL(string: "http://\(ip)/member/login")!
        
        // Header 세팅
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Body 세팅
        let bodyData: String = token.accessToken
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: bodyData)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("카카오 프로필 조회 중 오류: \(error)")
                completion(nil)
            } else if let data = data {
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJSON = responseJSON as? ProfileModel {
                    print("카카오 기반 유저 프로필 조회 성공: \(responseJSON)")
                    completion(responseJSON)
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