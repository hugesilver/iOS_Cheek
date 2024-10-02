//
//  RegisterDomainViewModel.swift
//  CHEEK
//
//  Created by 김태은 on 9/26/24.
//

import Foundation
import Combine

let EXIT_TIME: Int = 3

class RegisterDomainViewModel: ObservableObject {
    let ip = Bundle.main.object(forInfoDictionaryKey: "SERVER_IP") as! String
    var cancellables = Set<AnyCancellable>()
    
    // 타이머
    private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // 로딩 중
    @Published var isLoading: Bool = false
    
    // 전송 완료
    @Published var isSent: Bool = false
    
    // 알림창
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    // 타이머
    @Published var time: Int = EXIT_TIME
    
    // destination of navigation
    @Published var isDone: Bool = false
    
    // 거부됨
    func showError(message: String) {
        DispatchQueue.main.async {
            self.alertMessage = message
            self.showAlert = true
            self.isLoading = false
        }
    }
    
    // 도메인 검증
    func validateEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        return emailTest.evaluate(with: email)
    }
    
    // 도메인 분할
    func splitDomain(email: String) -> String? {
        let components = email.split(separator: "@")
        guard components.count == 2 else {
            return nil
        }
        return String(components[1])
    }
    
    // 도메인 등록
    func registerDomain(email: String) {
        isLoading = true
        
        guard let domain = splitDomain(email: email) else {
            print("registerDomain 함수 실행 중 도메인 분할 실패")
            showError(message: "이메일을 다시 확인해주세요.")
            return
        }
        
        var components = URLComponents(string: "\(ip)/email/register-domain")!
        
        components.queryItems = [
            URLQueryItem(name:"domain", value: domain)
        ]
        
        guard let url = components.url else {
            print("registerDomain 함수 내 URL 추출 실패")
            showError(message: "오류가 발생하였습니다.")
            return
        }
        
        // Header 세팅
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        CombinePublishers().urlSessionToString(req: request)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("registerDomain 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("registerDomain 함수 실행 중 요청 실패: \(error)")
                    self.showError(message: "요청 중 오류가 발생하였습니다.")
                }
            }, receiveValue: { data in
                if data == "ok" {
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.isSent = true
                    }
                }
                
                do {
                    let errorModel = try JSONDecoder().decode(ErrorModel.self, from: data.data(using: .utf8)!)
                    switch errorModel.errorCode {
                    case "E-006":
                        DispatchQueue.main.async {
                            self.showError(message: "이미 신청된 도메인입니다.")
                        }
                    default:
                        DispatchQueue.main.async {
                            self.showError(message: "요청 중 오류가 발생하였습니다.")
                        }
                    }
                } catch {
                    print("registerDomain 함수 실행 중 ErrorModel 변환 오류: \(error)")
                    self.showError(message: "처리 중 오류가 발생하였습니다.")
                }
            })
            .store(in: &cancellables)
                
    }
    
    func timerExit() {
        time = EXIT_TIME
        
        timer
            .sink { _ in
                if self.time > 0 {
                    self.time -= 1
                } else {
                    self.isDone = true
                    self.isSent = false
                    
                    // 타이머 종료
                    self.timer.upstream.connect().cancel()
                }
            }
            .store(in: &cancellables)
    }
}
