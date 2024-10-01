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
    
    // 이메일
    @Published private var email: String = ""
    
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
        guard let socialMedia: String = Keychain().read(key: "SOCIAL_MEDIA") else {
            completion(nil)
            return
        }
        
        switch socialMedia {
        case "KAKAO":
            KakaoAuthViewModel().checkToken() { isHasToken in
                if isHasToken {
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
        
        return CombinePublishers().urlSessionToString(req: request)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("checkUniqueNickname 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("checkUniqueNickname 함수 실행 중 요청 실패: \(error)")
                }
            }, receiveValue: { data in
                print(data)
                completion(data == "true")
            })
            .store(in: &cancellables)
    }
    
    func setProfile(profilePicture: UIImage?, nickname: String, information: String, isMentor: Bool, completion: @escaping (Bool) -> Void) {
        getEmail() { email in
            guard let email = email else {
                print("오류: 프로필 설정 중 이메일 없음")
                completion(false)
                return
            }
            
            let ip = Bundle.main.object(forInfoDictionaryKey: "SERVER_IP") as! String
            let url = URL(string: "\(ip)/member/profile")!
            
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
                "email": email,
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
            
            httpBody.append("--\(boundary)\r\n".data(using: .utf8)!)
            httpBody.append("Content-Disposition: form-data; name=\"profilePicture\"; filename=\"profile.jpg\"\r\n".data(using: .utf8)!)
            httpBody.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            
            if let profilePicture {
                httpBody.append(profilePicture.jpegData(compressionQuality: 0.5)!)
            }
            
            httpBody.append("\r\n".data(using: .utf8)!)
            
            // Boundary 끝 추가
            httpBody.append("--\(boundary)--\r\n".data(using: .utf8)!)
            
            request.httpBody = httpBody
            
            // 서버에 요청 보내기
            CombinePublishers().urlSessionToString(req: request)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("validateDomain 함수 실행 중 요청 성공")
                    case .failure(let error):
                        print("validateDomain 함수 실행 중 요청 실패: \(error)")
                        self.showError(message: "요청 중 오류가 발생하였습니다.")
                    }
                }, receiveValue: { data in
                    DispatchQueue.main.async {
                        self.isLoading = false
                        
                        if data != "ok" {
                            self.showError(message: "등록 중 오류가 발생하였습니다.")
                        }
                    }
                    completion(data == "ok")
                })
                .store(in: &self.cancellables)
        }
    }
}
