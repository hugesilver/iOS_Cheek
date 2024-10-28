//
//  StoryViewModel.swift
//  CHEEK
//
//  Created by 김태은 on 10/12/24.
//

import Foundation
import Combine

class StoryViewModel: ObservableObject {
    let skipTime: Double = 15
    
    private let ip = Bundle.main.object(forInfoDictionaryKey: "SERVER_IP") as! String
    private var cancellables = Set<AnyCancellable>()
    private var isPaused: Bool = false
    private var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    // 불러오기 카운트
    @Published var stories: [StoryModel] = []
    @Published var isAllLoaded: Bool = false
    
    // 인덱스
    @Published var currentIndex: Int = 0
    
    // 타이머
    @Published var timerProgress: Double = 0.0
    @Published var isTimeOver: Bool = false
    
    // 스토리들 불러오기
    func getStories(storyIds: [Int64]) {
        let publishers: [AnyPublisher<StoryModel, Error>] = storyIds.map { storyId in
            getStory(storyId: storyId)
        }
            
        Publishers.MergeMany(publishers)
            .collect()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("모든 스토리 요청 완료")
                case .failure(let error):
                    print("스토리 요청 중 오류 발생: \(error)")
                }
            }, receiveValue: { storiesArray in
                DispatchQueue.main.async {
                    // stories 순서에 맞게 정렬
                    self.stories = storiesArray
                        .filter { storyIds.contains($0.id) }
                        .sorted  { first, second in
                            guard let firstIndex = storyIds.firstIndex(of: first.id),
                                  let secondIndex = storyIds.firstIndex(of: second.id) else {
                                return false
                            }
                            return firstIndex < secondIndex
                        }
                    
                    self.isAllLoaded = true
                    self.timerStory()
                }
            })
            .store(in: &cancellables)
    }
    
    // 스토리 불러오기
    func getStory(storyId: Int64) -> AnyPublisher<StoryModel, Error> {
        let url = URL(string: "\(ip)/story/\(storyId)")!
        
        // Header 세팅
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return CombinePublishers().urlSession(req: request)
            .decode(type: StoryModel.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    // 스토리 타이머
    func timerStory() {
        timer
            .sink { _ in
                if self.timerProgress < 1.0 {
                    self.isTimeOver = false
                    self.timerProgress += 0.1 / self.skipTime
                } else {
                    self.isTimeOver = true
                }
            }
            .store(in: &cancellables)
    }
    
    // 타이머 종료
    func stopTimer() {
        self.timer.upstream.connect().cancel()
    }
    
    // 스토리 좋아요
    func likeStory() {
        let storyId: Int64 = stories[currentIndex].storyId
        
        let url = URL(string: "\(ip)/upvote/\(storyId)")!
        
        // Header 세팅
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        CombinePublishers().urlSession(req: request)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("likeStory 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("likeStory 함수 실행 중 요청 실패: \(error)")
                }
            }, receiveValue: { data in
                let dataString = String(data: data, encoding: .utf8)
                
                DispatchQueue.main.async {
                    if dataString == "ok" {
                        print("스토리 \(storyId)에 좋아요 toggle에 성공")
                    }
                }
            })
            .store(in: &cancellables)
    }
}
