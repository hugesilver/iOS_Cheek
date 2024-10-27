//
//  FollowViewModel.swift
//  CHEEK
//
//  Created by 김태은 on 10/15/24.
//

import Foundation
import Combine

class FollowViewModel: ObservableObject {
    private let ip = Bundle.main.object(forInfoDictionaryKey: "SERVER_IP") as! String
    private var cancellables = Set<AnyCancellable>()
    
    @Published var followers: [FollowModel] = []
    @Published var followings: [FollowModel] = []
    
    
    // 팔로워 조회
    func getFollowers(targetMemberId: Int64) {
        print("팔로워 조회 시도")
        
        let url = URL(string: "\(ip)/member-connection/follower/\(targetMemberId)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        
        CombinePublishers().urlSession(req: request)
            .decode(type: [FollowModel].self, decoder: JSONDecoder())
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("getFollowers 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("getFollowers 함수 실행 중 요청 실패: \(error)")
                }
            }, receiveValue: { data in
                DispatchQueue.main.async {
                    self.followers = data
                }
            })
            .store(in: &self.cancellables)
    }
    
    // 팔로잉 조회
    func getFollowings(targetMemberId: Int64) {
        print("팔로잉 조회 시도")
        
        let url = URL(string: "\(ip)/member-connection/following/\(targetMemberId)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        
        CombinePublishers().urlSession(req: request)
            .decode(type: [FollowModel].self, decoder: JSONDecoder())
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("getFollowings 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("getFollowings 함수 실행 중 요청 실패: \(error)")
                }
            }, receiveValue: { data in
                DispatchQueue.main.async {
                    self.followings = data
                }
            })
            .store(in: &self.cancellables)
    }
    
    // 팔로우
    func follow(toMemberId: Int64) {
        let url = URL(string: "\(ip)/member-connection/\(toMemberId)")!
        
        // Header 세팅
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        CombinePublishers().urlSession(req: request)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("follow 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("follow 함수 실행 중 요청 실패: \(error)")
                }
            }, receiveValue: { data in
                let dataString = String(data: data, encoding: .utf8)
                
                DispatchQueue.main.async {
                    if dataString == "ok" {
                        print("팔로우 성공")
                    }
                }
            })
            .store(in: &cancellables)
    }
    
    // 언팔로우
    func unfollow(toMemberId: Int64) {
        let url = URL(string: "\(ip)/member-connection/\(toMemberId)")!
        
        // Header 세팅
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        CombinePublishers().urlSession(req: request)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("unfollow 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("unfollow 함수 실행 중 요청 실패: \(error)")
                }
            }, receiveValue: { data in
                let dataString = String(data: data, encoding: .utf8)
                
                DispatchQueue.main.async {
                    if dataString == "ok" {
                        print("언팔로우 성공")
                    }
                }
            })
            .store(in: &cancellables)
    }
}
