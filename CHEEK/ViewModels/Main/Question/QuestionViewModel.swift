//
//  AddQuestionViewModel.swift
//  CHEEK
//
//  Created by 김태은 on 9/12/24.
//

import Foundation
import Combine

class QuestionViewModel: ObservableObject {
    private let ip = Bundle.main.object(forInfoDictionaryKey: "SERVER_IP") as! String
    private var cancellables = Set<AnyCancellable>()
    
    // 로딩 중
    @Published var isLoading: Bool = false
    
    // 알림창
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    // 질문
    @Published var questionModel: QuestionModel?
    @Published var answeredUserStories: [AnsweredQuestionModel] = []
    
    // 거부됨
    func showError(message: String) {
        DispatchQueue.main.async {
            self.alertMessage = message
            self.showAlert = true
            self.isLoading = false
        }
    }
    
    // 질문 조회
    func getQuestion(questionId: Int64) {
        print("질문 조회 시도")
        
        let url = URL(string: "\(ip)/question/\(questionId)")!
        
        // Header 세팅
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        CombinePublishers().urlSession(req: request)
            .decode(type: QuestionModel.self, decoder: JSONDecoder())
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("getQuestions 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("getQuestions 함수 실행 중 요청 실패: \(error)")
                    self.showError(message: "오류가 발생했습니다.")
                }
            }, receiveValue: { data in
                DispatchQueue.main.async {
                    self.questionModel = data
                }
            })
            .store(in: &self.cancellables)
    }
    
    // 질문 업로드
    func uploadQuestion(categoryId: Int64, content: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        
        let url = URL(string: "\(ip)/question")!
        
        // Header 세팅
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Body 세팅
        let bodyData: [String: Any] = [
            "content": content,
            "categoryId": categoryId
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: bodyData, options: [])
        } catch {
            print("질문 전송 JSON 변환 중 오류: \(error)")
            completion(false)
            return
        }
        
        CombinePublishers().urlSession(req: request)
            .sink(receiveCompletion: { isComplete in
                switch isComplete {
                case .finished:
                    print("uploadQuestion 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("uploadQuestion 함수 실행 중 요청 실패: \(error)")
                    completion(false)
                    self.showError(message: "질문 등록 중 오류가 발생하였습니다.")
                }
            }, receiveValue: { data in
                let dataString = String(data: data, encoding: .utf8)
                
                DispatchQueue.main.async {
                    if dataString == "ok" {
                        self.isLoading = false
                    } else {
                        self.showError(message: "질문 등록 중 오류가 발생하였습니다.")
                    }
                }
                
                completion(dataString == "ok")
            })
            .store(in: &cancellables)
    }
    
    // 질문 수정
    func editQuestion(content: String, questionId: Int64, completion: @escaping (Bool) -> Void) {
        isLoading = true
        
        let url = URL(string: "\(ip)/question")!
        
        // Header 세팅
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Body 세팅
        let bodyData: [String: Any] = [
            "content": content,
            "questionId": questionId
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: bodyData, options: [])
        } catch {
            print("질문 수정 JSON 변환 중 오류: \(error)")
            completion(false)
            return
        }
        
        CombinePublishers().urlSession(req: request)
            .sink(receiveCompletion: { isComplete in
                switch isComplete {
                case .finished:
                    print("editQuestion 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("editQuestion 함수 실행 중 요청 실패: \(error)")
                    completion(false)
                    self.showError(message: "질문 수정 중 오류가 발생하였습니다.")
                }
            }, receiveValue: { data in
                let dataString = String(data: data, encoding: .utf8)
                
                DispatchQueue.main.async {
                    if dataString == "ok" {
                        self.isLoading = false
                    } else {
                        self.showError(message: "질문 등록 중 오류가 발생하였습니다.")
                    }
                }
                
                completion(dataString == "ok")
            })
            .store(in: &cancellables)
    }
    
    // 답변된 스토리 목록 조회
    func getAnsweredQuestions(questionId: Int64) {
        print("답변된 스토리 목록 조회 시도")
        
        let url = URL(string: "\(ip)/story/\(questionId)/answered-stories")!
        
        // Header 세팅
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        CombinePublishers().urlSession(req: request)
            .decode(type: [AnsweredQuestionModel].self, decoder: JSONDecoder())
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("getAnsweredQuestions 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("getAnsweredQuestions 함수 실행 중 요청 실패: \(error)")
                }
            }, receiveValue: { data in
                DispatchQueue.main.async {
                    self.answeredUserStories = data
                }
            })
            .store(in: &self.cancellables)
    }
}
