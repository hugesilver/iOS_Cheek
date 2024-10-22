//
//  AddQuestionViewModel.swift
//  CHEEK
//
//  Created by 김태은 on 9/12/24.
//

import Foundation
import Combine

class AddQuestionViewModel: ObservableObject {
    private let ip = Bundle.main.object(forInfoDictionaryKey: "SERVER_IP") as! String
    private var cancellables = Set<AnyCancellable>()
    
    // 로딩 중
    @Published var isLoading: Bool = false
    
    // 알림창
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    // 거부됨
    func showError(message: String) {
        DispatchQueue.main.async {
            self.alertMessage = message
            self.showAlert = true
            self.isLoading = false
        }
    }
    
    // 질문 업로드
    func uploadQuestion(memberId: Int64, categoryId: Int64, content: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        
        let url = URL(string: "\(ip)/question")!
        
        // Header 세팅
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Body 세팅
        let bodyData: [String: Any] = [
            "content": content,
            "categoryId": categoryId,
            "memberId": memberId
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: bodyData, options: [])
        } catch {
            print("질문 전송 JSON 변환 중 오류: \(error)")
            completion(false)
            return
        }
        
        CombinePublishers().urlSession(req: request)
            .sink(receiveCompletion: { isCompletion in
                switch isCompletion {
                case .finished:
                    print("uploadQuestion 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("uploadQuestion 함수 실행 중 요청 실패: \(error)")
                    completion(false)
                    self.showError(message: "질문 등록 중 발생하였습니다.")
                }
            }, receiveValue: { data in
                let dataString = String(data: data, encoding: .utf8)
                
                DispatchQueue.main.async {
                    if dataString == "ok" {
                        self.isLoading = false
                    } else {
                        self.showError(message: "질문 등록 중 발생하였습니다.")
                    }
                }
                
                completion(dataString == "ok")
            })
            .store(in: &cancellables)
    }
}
