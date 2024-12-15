//
//  BlockViewModel.swift
//  CHEEK
//
//  Created by 김태은 on 12/16/24.
//

import Foundation
import Combine

class BlockViewModel: ObservableObject {
    private let ip = Bundle.main.object(forInfoDictionaryKey: "SERVER_IP") as! String
    private var cancellables = Set<AnyCancellable>()
    
    @Published var blockList: [BlockListModel]?
    @Published var index: Int?
    
    init() {
        getBlockList()
    }
    
    // 차단 목록 불러오기
    func getBlockList() {
        let url = URL(string: "\(ip)/block")!
        
        // Header 세팅
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        CombinePublishers().urlSession(req: request)
            .decode(type: [BlockListModel].self, decoder: JSONDecoder())
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("getBlockList 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("getBlockList 함수 실행 중 요청 실패: \(error)")
                }
            }, receiveValue: { data in
                DispatchQueue.main.async {
                    self.blockList = data
                }
            })
            .store(in: &cancellables)
    }
    
    // 차단
    func block(_ targetMemberId: Int64) {
        let url = URL(string: "\(ip)/block/\(targetMemberId)")!
        
        // Header 세팅
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        CombinePublishers().urlSession(req: request)
            .sink(receiveCompletion: { isComplete in
                switch isComplete {
                case .finished:
                    print("block 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("block 함수 실행 중 요청 실패: \(error)")
                }
            }, receiveValue: { data in
                DispatchQueue.main.async {
                    self.index = nil
                    self.getBlockList()
                }
            })
            .store(in: &cancellables)
    }
    
    // 차단 해제
    func unblock() {
        if blockList != nil && index != nil && index != -1 {
            let url = URL(string: "\(ip)/block/\(blockList![index!].blockId)")!
            
            // Header 세팅
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            CombinePublishers().urlSession(req: request)
                .sink(receiveCompletion: { isComplete in
                    switch isComplete {
                    case .finished:
                        print("unblock 함수 실행 중 요청 성공")
                    case .failure(let error):
                        print("unblock 함수 실행 중 요청 실패: \(error)")
                    }
                }, receiveValue: { data in
                    DispatchQueue.main.async {
                        self.blockList!.remove(at: self.index!)
                        self.index = -1
                    }
                })
                .store(in: &cancellables)
        }
    }
    
    // 특정 프로필의 blockList 내 index 찾기
    func getblockListIndex(_ targetMemberId: Int64) {
        if blockList != nil {
            index = blockList!.firstIndex(where: { $0.memberDto.memberId == targetMemberId }) ?? -1
        }
    }
}
