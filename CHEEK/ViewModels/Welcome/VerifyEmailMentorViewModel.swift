//
//  VerifyEmailMentorViewModel.swift
//  CHEEK
//
//  Created by 김태은 on 6/5/24.
//

import Foundation

class VerifyEmailMentorViewModel: ObservableObject {
    func validateEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    func splitDomain(email: String) -> String? {
        let components = email.split(separator: "@")
        guard components.count == 2 else {
            return nil
        }
        return String(components[1])
    }
    
    func validateDomain(email: String, completion: @escaping (Bool) -> Void) {
        guard let domain = splitDomain(email: email) else {
            completion(false)
            return
        }
        
        // 도메인 확인
        print(domain)
        
        let ip = Bundle.main.object(forInfoDictionaryKey: "SERVER_IP") as! String
        let url = URL(string: "http://\(ip)/email/domain/validate")!
        
        // Header 세팅
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("text/plain; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        // Body 세팅
        let bodyData: String = domain
        
        request.httpBody = bodyData.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("도메인 유효성 검증 중 오류: \(error)")
            } else if let data = data {
                if let dataString = String(data: data, encoding: .utf8) {
                    let response = (dataString as NSString).boolValue
                    print("도메인 유효성 검증 응답: \(response)")
                    completion(response)
                } else {
                    print("도메인 유효성 검증 응답 데이터를 문자열로 변환하는 데 실패했습니다.")
                    completion(false)
                }
            }
        }
        
        task.resume()
    }
    
    func registerDomain(email: String, completion: @escaping (String?) -> Void) {
        guard let domain = splitDomain(email: email) else {
            return
        }
        
        // 도메인 확인
        print(domain)
        
        let ip = Bundle.main.object(forInfoDictionaryKey: "SERVER_IP") as! String
        let url = URL(string: "http://\(ip)/email/register-domain")!
        
        // Header 세팅
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("text/plain; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        // Body 세팅
        let bodyData: String = domain
        
        request.httpBody = bodyData.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("도메인 등록 중 오류: \(error)")
                completion(nil)
            } else if let data = data {
                if let dataString = String(data: data, encoding: .utf8) {
                    print("도메인 등록 응답: \(dataString)")
                    completion(dataString)
                } else {
                    print("도메인 등록 응답 데이터를 문자열로 변환하는 데 실패했습니다.")
                    completion(nil)
                }
            }
        }
        
        task.resume()
    }
    
    func sendEmail(email: String, completion: @escaping (String?) -> Void) {
        let ip = Bundle.main.object(forInfoDictionaryKey: "SERVER_IP") as! String
        let url = URL(string: "http://\(ip)/email/send")!
        
        // Header 세팅
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Body 세팅
        let bodyData: VefiryEmailModel = VefiryEmailModel(email: email)!
        
        do {
            request.httpBody = try JSONEncoder().encode(bodyData)
        } catch {
            print("이메일 코드 전송 JSON 변환 중 오류: \(error)")
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("이메일 코드 전송 중 오류: \(error)")
                completion(nil)
            } else if let data = data {
                if let dataString = String(data: data, encoding: .utf8) {
                    print("이메일 코드 전송 응답: \(dataString)")
                    completion(dataString)
                } else {
                    print("이메일 코드 전송 응답 데이터를 문자열로 변환하는 데 실패했습니다.")
                    completion(nil)
                }
            }
        }
        
        task.resume()
    }
    
    func verifyEmailCode(email: String, verificationCode: String, completion: @escaping (String?) -> Void) {
        let ip = Bundle.main.object(forInfoDictionaryKey: "SERVER_IP") as! String
        let url = URL(string: "http://\(ip)/email/send")!
        
        // Header 세팅
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Body 세팅
        let bodyData: VefiryCodesModel = VefiryCodesModel(email: email, verificationCode: verificationCode)!
        
        do {
            request.httpBody = try JSONEncoder().encode(bodyData)
        } catch {
            print("확인 코드 검증 JSON 변환 중 오류: \(error)")
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("확인 코드 검증 중 오류: \(error)")
                completion(nil)
            } else if let data = data {
                if let dataString = String(data: data, encoding: .utf8) {
                    print("확인 코드 검증 응답: \(dataString)")
                    completion(dataString)
                } else {
                    print("확인 코드 검증 응답 데이터를 문자열로 변환하는 데 실패했습니다.")
                    completion(nil)
                }
            }
        }
        
        task.resume()
    }
}
