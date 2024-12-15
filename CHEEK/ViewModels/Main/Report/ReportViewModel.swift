//
//  ReportViewModel.swift
//  CHEEK
//
//  Created by 김태은 on 12/15/24.
//

import Foundation
import Combine

class ReportViewModel: ObservableObject {
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
    
    // 신고 제출
    func sendReport(category: String, categoryId: Int64, toMemberId: Int64, title: String, content: String) {
        isLoading = true
        
        let url = URL(string: "\(ip)/report")!
        
        // Header 세팅
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Body 세팅
        let bodyData: [String: Any] = [
            "category": category,
            "categoryId": categoryId,
            "toMemberId": toMemberId,
            "title": title,
            "content": content
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: bodyData, options: [])
        } catch {
            print("sendReport Body JSON 변환 중 오류: \(error)")
            return
        }
        
        CombinePublishers().urlSession(req: request)
            .sink(receiveCompletion: { isComplete in
                switch isComplete {
                case .finished:
                    print("sendReport 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("sendReport 함수 실행 중 요청 실패: \(error)")
                }
            }, receiveValue: { data in
                let dataString = String(data: data, encoding: .utf8)
                DispatchQueue.main.async {
                    if dataString == "ok" {
                        self.showError(message: "신고가 접수되었습니다.\n24시간 이내에 반영됩니다.")
                    } else {
                        self.showError(message: "제출 중 오류가 발생하였습니다.")
                    }
                }
            })
            .store(in: &cancellables)
    }
}
