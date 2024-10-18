//
//  HighlightViewModel.swift
//  CHEEK
//
//  Created by 김태은 on 10/11/24.
//

import Foundation
import Combine
import UIKit

class HighlightViewModel: ObservableObject {
    private let ip = Bundle.main.object(forInfoDictionaryKey: "SERVER_IP") as! String
    private var cancellables = Set<AnyCancellable>()
    
    // 로딩 중
    @Published var isLoading: Bool = false
    
    // 알림창
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    // 썸네일
    @Published var thumbnail: UIImage? = nil
    @Published var selectedImage: UIImage? = nil
    
    // 불러온 하이라이트
    @Published var highlights: [StoryModel] = []
    
    // 등록 완료
    @Published var isDone: Bool = false
    
    // 거부됨
    func showError(message: String) {
        DispatchQueue.main.async {
            self.alertMessage = message
            self.showAlert = true
            self.isLoading = false
        }
    }
    
    // 하이라이트 추가
    func addHighlight(stories: [StoryDto], subject: String, memberId: Int64, completion: @escaping (Bool) -> Void) {
        isLoading = true
        
        var storyIdList: [Int64] = []
        
        for story in stories {
            storyIdList.append(story.storyId)
        }
        
        let url = URL(string: "\(ip)/highlight/mentor")!
        
        // Boundary 설정
        let boundary = UUID().uuidString
        
        // Header 세팅
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Body 설정
        var httpBody = Data()
        
        let highlightDto: [String: Any] = [
            "storyIdList": storyIdList,
            "memberId": memberId,
            "subject": subject
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: highlightDto, options: .prettyPrinted) {
            httpBody.append("--\(boundary)\r\n".data(using: .utf8)!)
            httpBody.append("Content-Disposition: form-data; name=\"highlightDto\"\r\n".data(using: .utf8)!)
            httpBody.append("Content-Type: application/json\r\n\r\n".data(using: .utf8)!)
            httpBody.append(jsonData)
            httpBody.append("\r\n".data(using: .utf8)!)
        } else {
            showError(message: "등록 중 오류가 발생하였습니다.")
            print("addHighlight 함수 실행 중 jsonData 없음")
        }
        
        if let thumbnailPicture = thumbnail {
            httpBody.append("--\(boundary)\r\n".data(using: .utf8)!)
            httpBody.append("Content-Disposition: form-data; name=\"thumbnailPicture\"; filename=\"thumbnailPicture.jpg\"\r\n".data(using: .utf8)!)
            httpBody.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            httpBody.append(thumbnailPicture.jpegData(compressionQuality: 1.0)!)
            httpBody.append("\r\n".data(using: .utf8)!)
        } else {
            showError(message: "등록 중 오류가 발생하였습니다.")
            print("addHighlight 함수 실행 중 썸네일 없음")
        }
        
        // Boundary 끝 추가
        httpBody.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = httpBody
        
        CombinePublishers().urlSession(req: request)
            .sink(receiveCompletion: {isCompletion in
                switch isCompletion {
                case .finished:
                    print("postHighlight 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("postHighlight 함수 실행 중 요청 실패: \(error)")
                    self.showError(message: "하이라이트 등록 중 오류가 발생하였습니다.")
                    completion(false)
                }
            }, receiveValue: { data in
                let dataString = String(data: data, encoding: .utf8)
                
                DispatchQueue.main.async {
                    if dataString == "ok" {
                        self.isLoading = false
                    } else {
                        self.showError(message: "하이라이트 등록 중 오류가 발생하였습니다.")
                    }
                    
                    self.isDone = dataString == "ok"
                }
                
                completion(dataString == "ok")
            })
            .store(in: &cancellables)
    }
    
    func convertUIImage(url: String) {
        let url = URL(string: "\(url)")!
        
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap() { data, response in
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                    print("응답 코드: \(response)")
                }
                
                // 디버깅
                if let dataString = String(data: data, encoding: .utf8) {
                    print(dataString)
                }
                
                return data
            }
            .retry(1)
            .eraseToAnyPublisher()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("convertUIImage 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("convertUIImage 함수 실행 중 요청 실패: \(error)")
                }
            }, receiveValue: { data in
                DispatchQueue.main.async {
                    self.selectedImage = UIImage(data: data)
                }
            })
            .store(in: &cancellables)
    }
    
    // 하이라이트 세부 조회
    func getHighlight(highlightId: Int64, completion: @escaping (Bool) -> Void) {
        let url = URL(string: "\(ip)/highlight/\(highlightId)")!
        
        // Header 세팅
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        CombinePublishers().urlSession(req: request)
            .decode(type: [StoryModel].self, decoder: JSONDecoder())
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("getHighlight 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("getHighlight 함수 실행 중 요청 실패: \(error)")
                }
            }, receiveValue: { data in
                DispatchQueue.main.async {
                    self.highlights = data
                }
                
                completion(true)
            })
            .store(in: &cancellables)
    }
}
