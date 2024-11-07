//
//  AdminViewModel.swift
//  CHEEK
//
//  Created by 김태은 on 11/7/24.
//

import Foundation
import Combine

class AdminViewModel: ObservableObject {
    private let ip = Bundle.main.object(forInfoDictionaryKey: "SERVER_IP") as! String
    private var cancellables = Set<AnyCancellable>()
    
    @Published var memberList: [AdminMemberInfoModel] = []
    
    init() {
        getMemberInfo()
    }
    
    // 회원 정보 불러오기
    func getMemberInfo() {
        let url = URL(string: "\(ip)/member/info/all")!
        
        // Header 세팅
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        CombinePublishers().urlSession(req: request)
            .decode(type: [AdminMemberInfoModel].self, decoder: JSONDecoder())
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("getMemberInfo 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("getMemberInfo 함수 실행 중 요청 실패: \(error)")
                }
            }, receiveValue: { data in
                DispatchQueue.main.async {
                    self.memberList = data
                }
            })
            .store(in: &cancellables)
    }
    
    // 회원 역할 변경
    func changeMemberRole(memberId: Int64, role: String) {
        var components = URLComponents(string: "\(ip)/member/role")!
        
        components.queryItems = [
            URLQueryItem(name: "memberId", value: "\(memberId)"),
            URLQueryItem(name: "role", value: role)
        ]
        
        guard let url = components.url else {
            print("changeMemberRole 함수 내 URL 추출 실패")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        CombinePublishers().urlSession(req: request)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("changeMemberRole 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("changeMemberRole 함수 실행 중 요청 실패: \(error)")
                }
            }, receiveValue: { data in
                let dataString = String(data: data, encoding: .utf8)
                
                if dataString == "ok" {
                    DispatchQueue.main.async {
                        if let index = self.memberList.firstIndex(where: { $0.memberId == memberId }) {
                            self.memberList[index].role = role
                        }
                    }
                }
            })
            .store(in: &cancellables)
    }
}
