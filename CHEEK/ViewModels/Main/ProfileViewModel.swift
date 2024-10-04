//
//  ProfileViewModel.swift
//  CHEEK
//
//  Created by 김태은 on 6/13/24.
//

import Foundation
import Combine

class ProfileViewModel: ObservableObject {
    let ip = Bundle.main.object(forInfoDictionaryKey: "SERVER_IP") as! String
    var cancellables = Set<AnyCancellable>()
    
    // 프로필 model
    @Published var profile: ProfileModel? = nil
    
    func getProfile() {
        guard let accessToken: String = Keychain().read(key: "ACCESS_TOKEN") else {
            print("불러오기 실패")
            return
        }
        
        print("프로필 수신 시도 중")
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
        
        CombinePublishers().urlSession(req: request)
            .decode(type: ProfileModel.self, decoder: JSONDecoder())
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("validateDomain 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("validateDomain 함수 실행 중 요청 실패: \(error)")
                }
            }, receiveValue: { data in
                DispatchQueue.main.async {
                    self.profile = data
                }
            })
            .store(in: &self.cancellables)
    }
}

