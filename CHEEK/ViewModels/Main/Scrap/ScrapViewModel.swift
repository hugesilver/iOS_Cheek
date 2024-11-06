//
//  ScrapViewModel.swift
//  CHEEK
//
//  Created by 김태은 on 10/22/24.
//

import Foundation
import Combine

class ScrapViewModel: ObservableObject {
    private let ip = Bundle.main.object(forInfoDictionaryKey: "SERVER_IP") as! String
    private var cancellables = Set<AnyCancellable>()
    
    // 로딩 중
    @Published var isLoading: Bool = false
    
    // 스크랩 폴더 목록
    @Published var scrappedFolders: [ScrapFolderModel] = []
    
    // 선택한 스크랩 폴더
    @Published var selectedFolder: ScrapFolderModel? = nil
    
    // 선택한 스크랩 폴더 내 콜렉션 목록
    @Published var collections: [CollectionModel] = []
    
    // 스크랩된 폴더 조회
    func getScrappedFolders() {
        let url = URL(string: "\(ip)/folder")!
        
        // Header 세팅
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        CombinePublishers().urlSession(req: request)
            .decode(type: [ScrapFolderModel].self, decoder: JSONDecoder())
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("getScrappedFolders 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("getScrappedFolders 함수 실행 중 요청 실패: \(error)")
                }
            }, receiveValue: { data in
                DispatchQueue.main.async {
                    self.scrappedFolders = data
                }
            })
            .store(in: &cancellables)
    }
    
    // 콜렉션 조회
    func getCollections(folderId: Int64) {
        let url = URL(string: "\(ip)/folder/story/\(folderId)")!
        
        // Header 세팅
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        CombinePublishers().urlSession(req: request)
            .decode(type: [CollectionModel].self, decoder: JSONDecoder())
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("getCollections 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("getCollections 함수 실행 중 요청 실패: \(error)")
                }
            }, receiveValue: { data in
                DispatchQueue.main.async {
                    self.collections = data
                }
            })
            .store(in: &cancellables)
    }
    
    // 콜렉션 추가
    func addCollection(storyId: Int64, categoryId: Int64, forlderName: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        
        let url = URL(string: "\(ip)/collection")!
        
        // Header 세팅
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Body 세팅
        let bodyData: [String: Any] = [
            "storyId": storyId,
            "categoryId": categoryId,
            "folderName": forlderName
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: bodyData, options: [])
        } catch {
            print("컬렉션 추가 JSON 변환 중 오류: \(error)")
            completion(false)
            return
        }
        
        CombinePublishers().urlSession(req: request)
            .sink(receiveCompletion: { isComplete in
                switch isComplete {
                case .finished:
                    print("addCollection 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("addCollection 함수 실행 중 요청 실패: \(error)")
                    self.isLoading = false
                    completion(false)
                }
            }, receiveValue: { data in
                let dataString = String(data: data, encoding: .utf8)
                
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                
                completion(dataString == "ok")
            })
            .store(in: &cancellables)
    }
    
    func deleteCollections(collectionList: [CollectionModel], completion: @escaping (Bool) -> Void) {
        let url = URL(string: "\(ip)/collection")!
        
        // Header 세팅
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Body 세팅
        let collectionIdList: [Int64] = collectionList.map {
            $0.collectionId
        }
        
        let bodyData: [String: Any] = [
            "collectionIdList": collectionIdList,
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: bodyData, options: [])
        } catch {
            print("컬렉션 추가 JSON 변환 중 오류: \(error)")
            completion(false)
            return
        }
        
        CombinePublishers().urlSession(req: request)
            .sink(receiveCompletion: { isComplete in
                switch isComplete {
                case .finished:
                    print("deleteCollections 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("deleteCollections 함수 실행 중 요청 실패: \(error)")
                    completion(false)
                }
            }, receiveValue: { data in
                let dataString = String(data: data, encoding: .utf8)
                
                completion(dataString == "ok")
            })
            .store(in: &cancellables)
    }
    
    func deleteFolder(folderId: Int64, completion: @escaping (Bool) -> Void) {
        let url = URL(string: "\(ip)/folder/\(folderId)")!
        
        // Header 세팅
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        CombinePublishers().urlSession(req: request)
            .sink(receiveCompletion: { isComplete in
                switch isComplete {
                case .finished:
                    print("deleteFolder 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("deleteFolder 함수 실행 중 요청 실패: \(error)")
                    completion(false)
                }
            }, receiveValue: { data in
                let dataString = String(data: data, encoding: .utf8)
                
                completion(dataString == "ok")
            })
            .store(in: &cancellables)
    }
}
