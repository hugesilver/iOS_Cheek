//
//  ProfileViewModel.swift
//  CHEEK
//
//  Created by 김태은 on 6/13/24.
//

import Foundation

class ProfileViewModel: ObservableObject {
    @Published var profile: ProfileModel? = nil
    
    func getProfile() {
        guard let accessToken: String = Keychain().read(key: "ACCESS_TOKEN") else {
            print("불러오기 실패")
            return
        }
        
        print("프로필 수신 시도 중")
        let ip = Bundle.main.object(forInfoDictionaryKey: "SERVER_IP") as! String
        var components = URLComponents(string: "\(ip)/member/info")!
        
        components.queryItems = [
            URLQueryItem(name: "accessToken", value: "Bearer \(accessToken)")
        ]
        
        guard let url = components.url else {
            print("getProfile 함수 내 URL 추출 실패")
            return
        }
        
        // Header 세팅
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("프로필 조회 중 오류: \(error)")
            }
            
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let profileModel = try decoder.decode(ProfileModel.self, from: data)
                    
                    self.profile = profileModel
                } catch {
                    print("프로필 조회 후 데이터 변환 중 오류 발생: \(error)")
                }
            }
            
            if let response = response as? HTTPURLResponse {
                print("프로필 조회 응답 코드: \(response.statusCode)")
            }
        }
        
        task.resume()
    }
}

