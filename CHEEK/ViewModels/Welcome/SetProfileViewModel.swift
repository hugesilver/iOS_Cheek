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
        guard let accessToken: String = Keychain().read(key: "ACCESS_TOKEN") else {
            completion(false)
            return
        }
        
        let ip = Bundle.main.object(forInfoDictionaryKey: "SERVER_IP") as! String
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
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("닉네임 중복 확인 중 오류: \(error)")
                completion(false)
            }
            if let data = data {
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
    
    func setProfile(profilePicture: UIImage?, nickname: String, information: String, isMentor: Bool, completion: @escaping (Bool) -> Void) {
        guard let accessToken: String = Keychain().read(key: "ACCESS_TOKEN") else {
            completion(false)
            return
        }
        
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
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            
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
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("프로필 설정 중 오류: \(error)")
                    completion(false)
                    return
                }
                
                if let data = data {
                    // 응답 처리
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("프로필 설정 응답: \(responseString)")
                        completion(responseString == "ok")
                    } else {
                        print("프로필 설정 응답 String 변환 중 오류 발생")
                        completion(false)
                    }
                }
                
                if let response = response as? HTTPURLResponse {
                    print("프로필 설정 응답 코드: \(response.statusCode)")
                }
            }
            
            task.resume()
        }
    }
}
