//
//  SetProfileMentee.swift
//  CHEEK
//
//  Created by 김태은 on 5/29/24.
//

import Foundation
import Combine
import PhotosUI

class SetProfileViewModel: ObservableObject {
    let ip = Bundle.main.object(forInfoDictionaryKey: "SERVER_IP") as! String
    var cancellables = Set<AnyCancellable>()
    
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
    
    func getEmail(completion: @escaping (String?) -> Void) {
        guard let socialMedia: String = Keychain().read(key: "MEMBER_TYPE") else {
            completion(nil)
            return
        }
        
        switch socialMedia {
        case "KAKAO":
            KakaoAuthViewModel().checkToken() { haveToken in
                if haveToken {
                    KakaoAuthViewModel().getEmail() { email in
                        completion(email)
                    }
                }
            }
            break
            
        default:
            print("getEmail 함수 실행 중 socialMedia를 찾을 수 없음")
            completion(nil)
            break
        }
    }
    
    func checkUniqueNickname(nickname: String, completion: @escaping (Bool) -> Void) {
        var components = URLComponents(string: "\(ip)/member/check-nickname")!
        
        components.queryItems = [
            URLQueryItem(name: "nickname", value: nickname)
        ]
        
        guard let url = components.url else {
            print("checkUniqueNickname 함수 내 URL 추출 실패")
            completion(false)
            return
        }
        
        // Header 세팅
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        return CombinePublishers().urlSession(req: request)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("checkUniqueNickname 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("checkUniqueNickname 함수 실행 중 요청 실패: \(error)")
                }
            }, receiveValue: { data in
                let dataString = String(data: data, encoding: .utf8)
                completion(dataString == "true")
            })
            .store(in: &cancellables)
    }
    
    func setProfile(profilePicture: UIImage?, nickname: String, information: String, isMentor: Bool, completion: @escaping (Bool) -> Void) {
        let url = URL(string: "\(self.ip)/member/profile")!
        
        // Boundary 설정
        let boundary = UUID().uuidString
        
        // Header 설정
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Body 설정
        var httpBody = Data()
        
        // profileDto
        let profileDto: [String: Any] = [
            "nickname": nickname,
            "information": information,
            "role": isMentor ? "MENTOR" : "MENTEE"
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: profileDto, options: .prettyPrinted) {
            httpBody.append("--\(boundary)\r\n".data(using: .utf8)!)
            httpBody.append("Content-Disposition: form-data; name=\"profileDto\"\r\n".data(using: .utf8)!)
            httpBody.append("Content-Type: application/json\r\n\r\n".data(using: .utf8)!)
            httpBody.append(jsonData)
            httpBody.append("\r\n".data(using: .utf8)!)
        }
        
        if let profilePicture {
            httpBody.append("--\(boundary)\r\n".data(using: .utf8)!)
            httpBody.append("Content-Disposition: form-data; name=\"profilePicture\"; filename=\"profile.jpg\"\r\n".data(using: .utf8)!)
            httpBody.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            httpBody.append(profilePicture.jpegData(compressionQuality: 0.5)!)
            httpBody.append("\r\n".data(using: .utf8)!)
        }
        
        // Boundary 끝 추가
        httpBody.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = httpBody
        
        // 서버에 요청 보내기
        CombinePublishers().urlSession(req: request)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("setProfile 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("setProfile 함수 실행 중 요청 실패: \(error)")
                    self.showError(message: "요청 중 오류가 발생하였습니다.")
                }
            }, receiveValue: { data in
                let dataString = String(data: data, encoding: .utf8)
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    if dataString != "ok" {
                        self.showError(message: "등록 중 오류가 발생하였습니다.")
                    }
                }
                
                completion(dataString == "ok")
            })
            .store(in: &self.cancellables)
    }
    
    func editProfile(profilePicture: UIImage?, nickname: String, information: String, description: String, completion: @escaping (Bool) -> Void) {
        let url = URL(string: "\(ip)/member/profile")!
        
        // Boundary 설정
        let boundary = UUID().uuidString
        
        // Header 설정
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Body 설정
        var httpBody = Data()
        
        // profileDto
        let profileDto: [String: Any] = [
            "nickname": nickname,
            "information": information,
            "description": description
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: profileDto, options: .prettyPrinted) {
            httpBody.append("--\(boundary)\r\n".data(using: .utf8)!)
            httpBody.append("Content-Disposition: form-data; name=\"profileDto\"\r\n".data(using: .utf8)!)
            httpBody.append("Content-Type: application/json\r\n\r\n".data(using: .utf8)!)
            httpBody.append(jsonData)
            httpBody.append("\r\n".data(using: .utf8)!)
        }
        
        if let profilePicture {
            httpBody.append("--\(boundary)\r\n".data(using: .utf8)!)
            httpBody.append("Content-Disposition: form-data; name=\"profilePicture\"; filename=\"profile.jpg\"\r\n".data(using: .utf8)!)
            httpBody.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            httpBody.append(profilePicture.jpegData(compressionQuality: 0.5)!)
            httpBody.append("\r\n".data(using: .utf8)!)
        }
        
        // Boundary 끝 추가
        httpBody.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = httpBody
        
        // 서버에 요청 보내기
        CombinePublishers().urlSession(req: request)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("editProfile 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("editProfile 함수 실행 중 요청 실패: \(error)")
                    self.showError(message: "요청 중 오류가 발생하였습니다.")
                }
            }, receiveValue: { data in
                let dataString = String(data: data, encoding: .utf8)
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    if dataString != "ok" {
                        self.showError(message: "수정 중 오류가 발생하였습니다.")
                    }
                }
                
                completion(dataString == "ok")
            })
            .store(in: &self.cancellables)
    }
}
