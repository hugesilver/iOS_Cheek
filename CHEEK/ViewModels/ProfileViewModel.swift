//
//  ProfileViewModel.swift
//  CHEEK
//
//  Created by 김태은 on 6/13/24.
//

import Foundation

class ProfileViewModel: ObservableObject {
    func getProfile( completion: @escaping (ProfileModel?) -> Void) {
        guard let accessToken: String = Keychain().read(key: "ACCESS_TOKEN") else {
            completion(nil)
            return
        }
        
        print("프로필 수신 시도 중")
        let ip = Bundle.main.object(forInfoDictionaryKey: "SERVER_IP") as! String
        var components = URLComponents(string: "http://\(ip)/member/info")!
        
        components.queryItems = [
            URLQueryItem(name: "accessToken", value: accessToken)
        ]
        
        guard let url = components.url else {
            print("getProfile 함수 내 URL 추출 실패")
            completion(nil)
            return
        }
        
        // Header 세팅
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("프로필 조회 중 오류: \(error)")
                completion(nil)
            }
            
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let profileModel = try decoder.decode(ProfileModel.self, from: data)
                    
                    print("profileModel 변환 완료")
                    
                    completion(profileModel)
                } catch {
                    completion(nil)
                }
            }
        }
        
        task.resume()
    }
}

