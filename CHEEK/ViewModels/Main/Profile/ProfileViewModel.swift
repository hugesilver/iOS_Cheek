//
//  ProfileViewModel.swift
//  CHEEK
//
//  Created by 김태은 on 6/13/24.
//

import Foundation
import Combine

class ProfileViewModel: ObservableObject {
    private let ip = Bundle.main.object(forInfoDictionaryKey: "SERVER_IP") as! String
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isMentor: Bool = false
    
    // 프로필 model
    @Published var profile: ProfileModel? = nil
    
    @Published var followers: [FollowModel] = []
    @Published var followings: [FollowModel] = []
    
    @Published var highlights: [HighlightListModel] = []
    
    @Published var stories: [StoryDto] = []
    @Published var questions: [QuestionDto] = []
    
    // 프로필 조회
    func getMyProfile() {
        print("프로필 조회 시도")
        
        let url = URL(string: "\(ip)/member/info")!
        
        // Header 세팅
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        CombinePublishers().urlSession(req: request)
            .decode(type: ProfileModel.self, decoder: JSONDecoder())
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("getMyProfile 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("getMyProfile 함수 실행 중 요청 실패: \(error)")
                }
            }, receiveValue: { data in
                DispatchQueue.main.async {
                    self.profile = data
                    self.isMentor = data.role == "MENTOR"
                }
            })
            .store(in: &self.cancellables)
    }
    
    // 하이라이트 조회
    func getHighlights() {
        print("하이라이트 조회 시도")
        
        guard profile != nil else {
            print("프로필을 불러올 수 없음")
            return
        }
        
        let components = URLComponents(string: "\(ip)/highlight/member/\(profile!.memberId)")!
        
        guard let url = components.url else {
            print("getProfile 함수 내 URL 추출 실패")
            return
        }
        
        // Header 세팅
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        CombinePublishers().urlSession(req: request)
            .decode(type: [HighlightListModel].self, decoder: JSONDecoder())
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("getHighlights 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("getHighlights 함수 실행 중 요청 실패: \(error)")
                }
            }, receiveValue: { data in
                DispatchQueue.main.async {
                    self.highlights = data.reversed()
                }
            })
            .store(in: &self.cancellables)
    }
    
    // 프로필 조회
    func getStories(myId: Int64) {
        print("스토리 조회 시도")
        
        guard profile != nil else {
            print("프로필을 불러올 수 없음")
            return
        }
        
        var components = URLComponents(string: "\(ip)/story/member/\(profile!.memberId)")!
        
        components.queryItems = [
            URLQueryItem(name: "loginMemberId", value: "\(myId)")
        ]
        
        guard let url = components.url else {
            print("getProfile 함수 내 URL 추출 실패")
            return
        }
        
        // Header 세팅
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        CombinePublishers().urlSession(req: request)
            .decode(type: [StoryDto].self, decoder: JSONDecoder())
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("getStories 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("getStories 함수 실행 중 요청 실패: \(error)")
                }
            }, receiveValue: { data in
                DispatchQueue.main.async {
                    self.stories = data
                }
            })
            .store(in: &self.cancellables)
    }
    
    // 질문 조회
    func getQuestions() {
        print("질문 조회 시도")
        
        guard profile != nil else {
            print("프로필을 불러올 수 없음")
            return
        }
        
        let url = URL(string: "\(ip)/question/member/\(profile!.memberId)")!
        
        // Header 세팅
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        CombinePublishers().urlSession(req: request)
            .decode(type: [QuestionDto].self, decoder: JSONDecoder())
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("getQuestions 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("getQuestions 함수 실행 중 요청 실패: \(error)")
                }
            }, receiveValue: { data in
                DispatchQueue.main.async {
                    self.questions = data
                }
            })
            .store(in: &self.cancellables)
    }
    
    // 팔로워 조회
    func getFollowers(myId: Int64) {
        print("팔로워 조회 시도")
        
        guard profile != nil else {
            print("프로필을 불러올 수 없음")
            return
        }
        
        var components = URLComponents(string: "\(ip)/member-connection/follower/\(profile!.memberId)")!
        
        components.queryItems = [
            URLQueryItem(name: "loginMemberId", value: "\(myId)")
        ]
        
        guard let url = components.url else {
            print("getFollowers 함수 내 URL 추출 실패")
            return
        }
        
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
    func getFollowings(myId: Int64) {
        print("팔로잉 조회 시도")
        
        guard profile != nil else {
            print("프로필을 불러올 수 없음")
            return
        }
        
        var components = URLComponents(string: "\(ip)/member-connection/following/\(profile!.memberId)")!
        
        components.queryItems = [
            URLQueryItem(name: "loginMemberId", value: "\(myId)")
        ]
        
        guard let url = components.url else {
            print("getFollowings 함수 내 URL 추출 실패")
            return
        }
        
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
}

