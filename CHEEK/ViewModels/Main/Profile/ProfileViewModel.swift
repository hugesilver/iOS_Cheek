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
    
    // 멘토 유무
    @Published var isMentor: Bool = false
    
    // 프로필 model
    @Published var profile: ProfileModel?
    
    // 하이라이트 목록
    @Published var highlights: [HighlightListModel] = []
    
    // 스토리 목록
    @Published var stories: [StoryDto] = []
    
    // 질문 목록
    @Published var questions: [QuestionDto] = []
    
    // 삭제할 스토리 목록
    @Published var selectedStoriesForDelete: [StoryDto] = []
    
    // 프로필 조회
    func getProfile(targetMemberId: Int64) {
        print("프로필 조회 시도")
        
        let url = URL(string: "\(ip)/member/info/\(targetMemberId)")!
        
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
    func getHighlights(targetMemberId: Int64) {
        print("하이라이트 조회 시도")
        
        let url = URL(string: "\(ip)/highlight/member/\(targetMemberId)")!
        
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
    
    // 스토리 조회
    func getStories(targetMemberId: Int64) {
        print("스토리 조회 시도")
        
        let url = URL(string: "\(ip)/story/member/\(targetMemberId)")!
        
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
    func getQuestions(targetMemberId: Int64) {
        print("질문 조회 시도")
        
        let url = URL(string: "\(ip)/question/member/\(targetMemberId)")!
        
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
    
    // 스토리 삭제
    func deleteStories() {
        let storyIds = selectedStoriesForDelete.map { $0.storyId }
        
        let url = URL(string: "\(ip)/story")!
        
        // Header 세팅
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Body 세팅
        let bodyData: [String: Any] = [
            "storyId": storyIds
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: bodyData, options: [])
        } catch {
            print("스토리 좋아요 JSON 변환 중 오류: \(error)")
            return
        }
        
        CombinePublishers().urlSession(req: request)
            .sink(receiveCompletion: { isComplete in
                switch isComplete {
                case .finished:
                    print("deleteStories 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("deleteStories 함수 실행 중 요청 실패: \(error)")
                }
            }, receiveValue: { data in
                let dataString = String(data: data, encoding: .utf8)
                
                if dataString == "ok" {
                    self.stories.removeAll { self.selectedStoriesForDelete.contains($0) }
                    self.selectedStoriesForDelete.removeAll()
                }
            })
            .store(in: &cancellables)
    }
}

