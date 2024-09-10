//
//  AuthenticationViewModel.swift
//  CHEEK
//
//  Created by 김태은 on 9/9/24.
//

import Foundation

class AuthenticationViewModel: ObservableObject {
    func autoSignIn(completion: @escaping (Bool) -> Void) {
        if let socialMediaName = Keychain().read(key: "SOCIAL_MEDIA") {
            switch socialMediaName {
            case "KAKAO":
                KakaoAuthViewModel().checkToken() { success in
                    completion(success)
                }
                break;
            case "APPLE":
                completion(true)
                break
            default:
                deleteSocialMediaSignIn()
                completion(false)
                break
            }
        }
    }
    
    func deleteSocialMediaSignIn() {
        Keychain().delete(key: "SOCIAL_MEDIA")
    }
}
