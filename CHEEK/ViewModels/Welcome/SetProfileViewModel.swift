//
//  SetProfileMentee.swift
//  CHEEK
//
//  Created by 김태은 on 5/29/24.
//

import Foundation
import PhotosUI

class SetProfileViewModel: ObservableObject {
    func getEmail(completion: @escaping (String?) -> Void) {
        /*
        if socialProvider == "Kakao" {
            KakaoAuthViewModel().checkToken() { isHasToken in
                if isHasToken {
                    KakaoAuthViewModel().getEmail() { email in
                        completion(email)
                    }
                }
            }
        }
         */
    }
    
    func checkUniqueNickname(nickname: String, completion: @escaping (Bool) -> Void) {
        let ip = Bundle.main.object(forInfoDictionaryKey: "SERVER_IP") as! String
        var components = URLComponents(string: "http://\(ip)/member/check-nickname")!
        
        components.queryItems = [
            URLQueryItem(name:"nickname", value: nickname)
        ]
        
        guard let url = components.url else {
            print("checkUniqueNickname 함수 내 URL 추출 실패")
            completion(false)
            return
        }
        
        // Header 세팅
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("닉네임 중복 확인 중 오류: \(error)")
                completion(false)
            } else if let data = data {
                if let dataString = String(data: data, encoding: .utf8) {
                    let response = (dataString as NSString).boolValue
                    print("닉네임 중복 확인 응답: \(response)")
                    completion(response)
                } else {
                    print("닉네임 중복 확인 응답 데이터를 문자열로 변환하는 데 실패했습니다.")
                    completion(false)
                }
            }
        }
        
        task.resume()
    }
    
    func setProfile(nickname: String?, information: String?, isMentor: Bool, profilePicture: UIImage?, completion: @escaping (Bool) -> Void) {
        getEmail() { email in
            guard let email = email else {
                print("오류: 멘티 프로필 설정 중 이메일 없음")
                completion(false)
                return
            }
            
            let ip = Bundle.main.object(forInfoDictionaryKey: "SERVER_IP") as! String
            let url = URL(string: "http://\(ip)/member/profile")!
            
            // Header 세팅
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            // Body 세팅
            let profileDto = [
                "email": email,
                "nickname": nickname ?? "",
                "information": information ?? "",
                "role": isMentor ? "MENTOR" : "MENTEE"
            ]
            
            var httpBody = Data()
            
            let boundary = UUID().uuidString
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            let jsonEncoder = JSONEncoder()
            if let jsonData = try? jsonEncoder.encode(profileDto) {
                httpBody.append("--\(boundary)\r\n".data(using: .utf8)!)
                httpBody.append("Content-Disposition: form-data; name=\"profileDto\"\r\n".data(using: .utf8)!)
                httpBody.append("Content-Type: application/json\r\n\r\n".data(using: .utf8)!)
                httpBody.append(jsonData)
                httpBody.append("\r\n".data(using: .utf8)!)
            }
            
            if profilePicture != nil {
                // 이미지 데이터 생성
                let profilePictureData = profilePicture?.jpegData(compressionQuality: 1.0)
                
                // 이미지 데이터 추가
                httpBody.append("--\(boundary)\r\n".data(using: .utf8)!)
                httpBody.append("Content-Disposition: form-data; name=\"profilePicture\"; filename=\"profile.jpg\"\r\n".data(using: .utf8)!)
                httpBody.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                httpBody.append(profilePictureData!)
                httpBody.append("\r\n".data(using: .utf8)!)
            }
            
            // 마지막 경계 추가
            httpBody.append("--\(boundary)--\r\n".data(using: .utf8)!)
            
            // HTTP 본문 설정
            request.httpBody = httpBody
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("멘티 프로필 정보 전송 중 오류: \(error)")
                    completion(false)
                } else if let data = data {
                    // 응답 처리
                    let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                    if let responseJSON = responseJSON as? [String: Any] {
                        print("멘티 프로필 설정 전송 응답: \(responseJSON)")
                    }
                    completion(true)
                }
            }
            
            task.resume()
        }
    }
}
