//
//  TopMembersViewModel.swift
//  CHEEK
//
//  Created by 김태은 on 10/9/24.
//

import Foundation
import Combine

class TopMembersViewModel: ObservableObject {
    @Published var topMembers: [MemberProfileModel] = []
    
    let ip = Bundle.main.object(forInfoDictionaryKey: "SERVER_IP") as! String
    var cancellables = Set<AnyCancellable>()
    
    func getTopMembers() {
        let url = URL(string: "\(ip)/member/top-members")!
        
        // Header 세팅
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        CombinePublishers().urlSession(req: request)
            .decode(type: [MemberProfileModel].self, decoder: JSONDecoder())
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("getTopMembers 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("getTopMembers 함수 실행 중 요청 실패: \(error)")
                }
            }, receiveValue: { data in
                DispatchQueue.main.async {
                    self.topMembers = data
                }
            })
            .store(in: &cancellables)
    }
}
