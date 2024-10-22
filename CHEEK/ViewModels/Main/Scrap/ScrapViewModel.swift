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
    
    @Published var scrappedFolders: [ScrapFolderModel] = []
    
    @Published var selectedFolder: ScrapFolderModel? = nil
    @Published var collections: [CollectionModel] = []
    
    func getScrappedFolders(myId: Int64) {
        let url = URL(string: "\(ip)/folder/\(myId)")!
        
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
                    print("getScrappedFolders 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("getScrappedFolders 함수 실행 중 요청 실패: \(error)")
                }
            }, receiveValue: { data in
                DispatchQueue.main.async {
                    self.collections = data
                }
            })
            .store(in: &cancellables)
    }
    
    func addCollection(myId: Int64, storyId: Int64, categoryId: Int64, forlderName: String, completion: @escaping (Bool) -> Void) {
        let url = URL(string: "\(ip)/collection")!
        
        // Header 세팅
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Body 세팅
        let bodyData: [String: Any] = [
            "memberId": myId,
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
            .sink(receiveCompletion: { isCompletion in
                switch isCompletion {
                case .finished:
                    print("addCollection 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("addCollection 함수 실행 중 요청 실패: \(error)")
                    completion(false)
                }
            }, receiveValue: { data in
                let dataString = String(data: data, encoding: .utf8)
                
                DispatchQueue.main.async {
                    if dataString == "ok" {
                        
                    } else {
                        print(dataString)
                    }
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
            .sink(receiveCompletion: { isCompletion in
                switch isCompletion {
                case .finished:
                    print("deleteCollections 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("deleteCollections 함수 실행 중 요청 실패: \(error)")
                    completion(false)
                }
            }, receiveValue: { data in
                let dataString = String(data: data, encoding: .utf8)
                
                DispatchQueue.main.async {
                    if dataString == "ok" {
                        
                    } else {
                        print(dataString)
                    }
                }
                
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
            .sink(receiveCompletion: { isCompletion in
                switch isCompletion {
                case .finished:
                    print("deleteFolder 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("deleteFolder 함수 실행 중 요청 실패: \(error)")
                    completion(false)
                }
            }, receiveValue: { data in
                let dataString = String(data: data, encoding: .utf8)
                
                DispatchQueue.main.async {
                    if dataString == "ok" {
                        
                    } else {
                        print(dataString)
                    }
                }
                
                completion(dataString == "ok")
            })
            .store(in: &cancellables)
    }
}
