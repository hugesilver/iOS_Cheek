//
//  FeedViewModel.swift
//  CHEEK
//
//  Created by 김태은 on 10/14/24.
//

import Foundation
import Combine

class FeedViewModel: ObservableObject {
    private let ip = Bundle.main.object(forInfoDictionaryKey: "SERVER_IP") as! String
    private var cancellables = Set<AnyCancellable>()
    
    // 피드
    @Published var feedNewest: [FeedModel] = []
    @Published var feedPopularity: [FeedModel] = []
    
    func getFeed(categoryId: Int64, myId: Int64) {
        feedNewest = []
        feedPopularity = []
        
        print("피드 조회 시도")
        
        var components = URLComponents(string: "\(ip)/feed/\(categoryId)")!
        
        components.queryItems = [
            URLQueryItem(name: "loginMemberId", value: "\(myId)")
        ]
        
        guard let url = components.url else {
            print("getFeed 함수 내 URL 추출 실패")
            return
        }
        
        // Header 세팅
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        CombinePublishers().urlSession(req: request)
            .decode(type: [FeedModel].self, decoder: JSONDecoder())
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("getFeed 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("getFeed 함수 실행 중 요청 실패: \(error)")
                }
            }, receiveValue: { data in
                DispatchQueue.main.async {
                    self.feedNewest = data
                    self.feedPopularity = data.filter { $0.type == "STORY" && $0.storyDto != nil}.sorted(by: {$0.storyDto!.upvoteCount > $1.storyDto!.upvoteCount})
                    
                }
            })
            .store(in: &self.cancellables)
    }
}
