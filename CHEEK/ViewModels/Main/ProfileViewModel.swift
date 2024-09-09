//
//  ProfileViewModel.swift
//  CHEEK
//
//  Created by 김태은 on 6/13/24.
//

import Foundation

class ProfileViewModel: ObservableObject {
    func getProfile(socialProvider: String, completion: @escaping (ProfileModel?) -> Void) {
        switch socialProvider {
        case "Kakao":
            // KakaoAuthViewModel().getProfileFromKakao(token: ) {}
            break
        default:
            completion(nil)
        }
    }
}

