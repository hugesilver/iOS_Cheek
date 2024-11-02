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
    private var cancellables = Set<AnyCancellable>()
    
    // 카카오 토큰 확인
    func checkToken(completion: @escaping (Bool) -> Void) {
        if (AuthApi.hasToken()) {
            completion(true)
        } else {
            print("카카오 토큰 유효하지 않음")
            completion(false)
        }
    }
    
    // 카카오 로그인
    func kakaoAuth(completion: @escaping (String?) -> Void) {
        if (UserApi.isKakaoTalkLoginAvailable()) {
            UserApi.shared.loginWithKakaoTalk { (oauthToken, error) in
                if let error = error {
                    print("카카오톡 앱을 통하여 로그인 중 오류: \(error)")
                    completion(nil)
                }
                
                if oauthToken != nil {
                    print("카카오톡 앱을 통하여 로그인 성공: \(String(describing: oauthToken))")
                    
                    // 액세스 토큰 복사 테스트용 코드
                    UIPasteboard.general.string = oauthToken?.accessToken
                    
                    completion(oauthToken?.accessToken)
                    return
                }
            }
        } else {
            UserApi.shared.loginWithKakaoAccount { (oauthToken, error) in
                if let error = error {
                    print("카카오톡 웹사이트를 통하여 로그인 중 오류: \(error)")
                    completion(nil)
                }
                
                if oauthToken != nil {
                    print("카카오톡 웹사이트를 통하여 로그인 성공: \(String(describing: oauthToken))")
                    
                    // 액세스 토큰 복사 테스트용 코드
                    UIPasteboard.general.string = oauthToken?.accessToken
                    
                    completion(oauthToken?.accessToken)
                    return
                }
            }
        }
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
