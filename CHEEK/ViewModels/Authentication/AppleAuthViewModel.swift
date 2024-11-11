//
//  AppleAuthViewModel.swift
//  CHEEK
//
//  Created by 김태은 on 11/7/24.
//

import Foundation
import AuthenticationServices
import CryptoKit
import Combine
import UIKit

class AppleAuthViewModel: NSObject, ObservableObject, ASAuthorizationControllerDelegate {
    fileprivate var currentNonce: String?
    
    private let ip = Bundle.main.object(forInfoDictionaryKey: "SERVER_IP") as! String
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isComplete: Bool? = nil
    @Published var profileComplete: Bool? = nil
    
    // 난수 생성
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    // SHA256 암호화
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    // 애플 로그인
    func signIn() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard currentNonce != nil else {
                print("Invalid state: A login callback was received, but no login request was sent.")
                self.isComplete = false
                return
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                self.isComplete = false
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                self.isComplete = false
                return
            }
            
            oAuthLogin(token: idTokenString)
            UIPasteboard.general.string = idTokenString
        } else {
            self.isComplete = false
        }
    }
    
    // 서버에 카카오 토큰 전송 및 토큰 발급
    func oAuthLogin(token: String) {
        print("APPLE 로그인 시도")
        
        let url = URL(string: "\(ip)/oauth/login")!
        
        // Header 세팅
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Body 세팅
        let bodyData: [String: Any] = [
            "memberType": "APPLE"
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: bodyData, options: [])
        } catch {
            print("OAuth Login JSON 변환 중 오류: \(error)")
            self.isComplete = false
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap() { data, response in
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                    print("응답 코드: \(response)")
                }
                
                // 디버깅
                if let dataString = String(data: data, encoding: .utf8) {
                    print(dataString)
                }
                
                return data
            }
            .retry(1)
            .eraseToAnyPublisher()
            .decode(type: OAuthLoginResponseModel.self, decoder: JSONDecoder())
            .sink(receiveCompletion: { isComplete in
                switch isComplete {
                case .finished:
                    print("oauthLogin 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("oauthLogin 함수 실행 중 요청 실패: \(error)")
                    self.isComplete = false
                }
            }, receiveValue: { data in
                Keychain().create(key: "MEMBER_TYPE", value: "APPLE")
                Keychain().create(key: "MEMBER_ID", value: "\(data.memberId)")
                Keychain().create(key: "ACCESS_TOKEN", value: data.accessToken)
                Keychain().create(key: "ACCESS_TOKEN_EXPIRE_TIME", value: data.accessTokenExpireTime)
                Keychain().create(key: "REFRESH_TOKEN", value: data.refreshToken)
                Keychain().create(key: "REFRESH_TOKEN_EXPIRE_TIME", value: data.refreshTokenExpireTime)
                
                DispatchQueue.main.async {
                    self.profileComplete = data.profileComplete
                    self.isComplete = true
                }
            })
            .store(in: &cancellables)
    }
}
