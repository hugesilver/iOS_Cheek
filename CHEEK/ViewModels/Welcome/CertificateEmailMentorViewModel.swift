//
//  VerifyEmailMentorViewModel.swift
//  CHEEK
//
//  Created by 김태은 on 6/5/24.
//

import Foundation
import Combine

let CODE_EXPIRE_TIME: Int = 180
let RESEND_TIME: Int = 60

class CertificateEmailMentorViewModel: ObservableObject {
    let ip = Bundle.main.object(forInfoDictionaryKey: "SERVER_IP") as! String
    var cancellables = Set<AnyCancellable>()
    
    // 타이머
    private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // 로딩 중
    @Published var isLoading: Bool = false
    
    // 인증번호 관련
    @Published var isSent: Bool = false
    
    // 인증번호 확인
    @Published var isSendable: Bool = true
    @Published var isVerificationCodeChecked: Bool = false
    
    // 알림창
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    // 팝업창
    @Published var showPopup: Bool = false
    
    // 인증번호 관련 타이머
    @Published var codeExpireTime: Int = CODE_EXPIRE_TIME
    @Published var resendTime: Int = RESEND_TIME
    
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
    
    // 도메인 인증
    func validateDomain(email: String) {
        isLoading = true
        
        guard let domain = splitDomain(email: email) else {
            print("validateDomain 함수 실행 중 도메인 분할 실패")
            showError(message: "이메일을 다시 확인해주세요.")
            return
        }
        
        var components = URLComponents(string: "\(ip)/email/verify-domain")!
        
        components.queryItems = [
            URLQueryItem(name: "domain", value: domain)
        ]
        
        guard let url = components.url else {
            print("validateDomain 함수 내 URL 추출 실패")
            showError(message: "오류가 발생하였습니다.")
            return
        }
        
        // Header 세팅
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        CombinePublishers().urlSession(req: request)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("validateDomain 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("validateDomain 함수 실행 중 요청 실패: \(error)")
                    self.showError(message: "요청 중 오류가 발생하였습니다.")
                }
            }, receiveValue: { data in
                let dataString = String(data: data, encoding: .utf8)
                
                DispatchQueue.main.async {
                    if dataString == "true" {
                        self.sendEmail(email: email)
                    } else {
                        self.showPopup = true
                        self.isLoading = false
                    }
                }
            })
            .store(in: &cancellables)
    }
    
    // 인증번호 포함된 이메일 전송
    func sendEmail(email: String) {
        isSent = false
        
        let url = URL(string: "\(ip)/email/send")!
        
        // Header 세팅
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Body 세팅
        let bodyData: VefiryEmailModel = VefiryEmailModel(email: email)!
        
        do {
            request.httpBody = try JSONEncoder().encode(bodyData)
        } catch {
            print("이메일 코드 전송 JSON 변환 중 오류: \(error)")
            showError(message: "오류가 발생하였습니다.")
            return
        }
        
        CombinePublishers().urlSession(req: request)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("sendEmail 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("sendEmail 함수 실행 중 요청 실패: \(error)")
                    self.showError(message: "요청 중 오류가 발생하였습니다.")
                }
            }, receiveValue: { data in
                let dataString = String(data: data, encoding: .utf8)
                
                if dataString == "ok" {
                    DispatchQueue.main.async {
                        self.isSent = true
                        self.isSendable = false
                        self.isLoading = false
                    }
                }
                
                do {
                    let errorModel = try JSONDecoder().decode(ErrorModel.self, from: data)
                    switch errorModel.errorCode {
                    case "E-002":
                        DispatchQueue.main.async {
                            self.showError(message: "이미 등록된 이메일 입니다.")
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
    
    // 인증번호 확인
    func verifyEmailCode(email: String, verificationCode: String) {
        isLoading = true
        
        let url = URL(string: "\(ip)/email/verify-code")!
        
        // Header 세팅
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Body 세팅
        let bodyData: VerifyCodesModel = VerifyCodesModel(email: email, verificationCode: verificationCode)!
        
        do {
            request.httpBody = try JSONEncoder().encode(bodyData)
        } catch {
            print("확인 코드 검증 JSON 변환 중 오류: \(error)")
            showError(message: "오류가 발생하였습니다.")
            return
        }
        
        CombinePublishers().urlSession(req: request)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("verifyEmailCode 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("verifyEmailCode 함수 실행 중 요청 실패: \(error)")
                    self.showError(message: "요청 중 오류가 발생하였습니다.")
                }
            }, receiveValue: { data in
                let dataString = String(data: data, encoding: .utf8)
                
                DispatchQueue.main.async {
                    if dataString == "ok" {
                        self.isVerificationCodeChecked = true
                        self.isLoading = false
                    } else {
                        self.showError(message: "인증번호를 다시 확인해주세요.")
                    }
                }
            })
            .store(in: &cancellables)
    }
    
    // 재전송 타이머
    func timerResendTime() {
        resendTime = RESEND_TIME
        
        timer
            .sink { _ in
                if self.resendTime > 0 {
                    self.resendTime -= 1
                } else {
                    self.isSendable = true
                }
            }
            .store(in: &cancellables)
    }

    // 인증번호 타이머
    func timerCodeExpireTime() {
        codeExpireTime = CODE_EXPIRE_TIME
        
        timer
            .sink { _ in
                if self.isSent {
                    if self.codeExpireTime > 0 {
                        self.codeExpireTime -= 1
                    } else {
                        self.isSent = false
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    // 타이머 종료
    func cancelTimer() {
        self.timer.upstream.connect().cancel()
    }
}
