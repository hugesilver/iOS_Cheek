//
//  SearchViewModel.swift
//  CHEEK
//
//  Created by 김태은 on 10/14/24.
//

import Foundation
import Combine

class SearchViewModel: ObservableObject {
    private let ip = Bundle.main.object(forInfoDictionaryKey: "SERVER_IP") as! String
    private var cancellables = Set<AnyCancellable>()
    private let defaults = UserDefaults.standard
    private let recentSearchedKey: String = "recentSearched"
    
    @Published var recentSearches: [String] = []
    @Published var trendingKeywords: [String] = []
    @Published var isSearched: Bool = false
    @Published var searchResult = []
    
    func getTrendingKeywords() {
        let url = URL(string: "\(ip)/search/trending-keyword")!
        
        // Header 세팅
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        CombinePublishers().urlSession(req: request)
            .decode(type: TrendingKeywordsModel.self, decoder: JSONDecoder())
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("getTrendingKeywords 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("getTrendingKeywords 함수 실행 중 요청 실패: \(error)")
                }
            }, receiveValue: { data in
                DispatchQueue.main.async {
                    self.trendingKeywords = data.keyword
                }
            })
            .store(in: &cancellables)
    }
    
    // 최근 검색 조회
    func getRecentSearched() {
        if let savedRecentSearched = defaults.stringArray(forKey: recentSearchedKey) {
            recentSearches = savedRecentSearched.reversed()
        }
    }
    
    // 최근 검색 추가
    func saveSearched(string: String) {
        var stringArray = defaults.stringArray(forKey: recentSearchedKey) ?? [String]()
        stringArray.append(string)
        defaults.set(stringArray, forKey: recentSearchedKey)
    }
    
    // 최근 검색 전체 삭제
    func removeAllSearched() {
        defaults.removeObject(forKey: recentSearchedKey)
    }
}
