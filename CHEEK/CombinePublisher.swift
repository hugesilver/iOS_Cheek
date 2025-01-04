//
//  Publishers.swift
//  CHEEK
//
//  Created by 김태은 on 10/1/24.
//

import Foundation
import Combine

class CombinePublishers: ObservableObject {
    private let ip = Bundle.main.object(forInfoDictionaryKey: "SERVER_IP") as! String
    private var cancellable: AnyCancellable?
    private var isAlreadyRequesting = false
    
    func checkRefreshTokenValid() -> Bool {
        guard let _ = Keychain().read(key: "REFRESH_TOKEN"),
              let refreshTokenExpireTime = Keychain().read(key: "REFRESH_TOKEN_EXPIRE_TIME"),
              let refreshTokenExpireTimeToDate = convertTokenTime(timeString: refreshTokenExpireTime) else {
            return false
        }
        
        return refreshTokenExpireTimeToDate >= Date()
    }
    
    func urlSession(req: URLRequest) -> AnyPublisher<Data, Error> {
        // combine urlsession
        guard let accessToken: String = Keychain().read(key: "ACCESS_TOKEN") else {
            print("ACCESS_TOKEN 불러오기 실패")
            return Fail(error: URLError(.clientCertificateRequired)).eraseToAnyPublisher()
        }
        
        if !self.checkRefreshTokenValid() {
            print("REFRESH_TOKEN 만료")
            return Fail(error: URLError(.clientCertificateRequired)).eraseToAnyPublisher()
        }
        
        var request: URLRequest = req
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap() { data, response in
                if let httpResponse = response as? HTTPURLResponse {
                    switch httpResponse.statusCode {
                    case 200:
                        print("응답 성공")
                    case 401:
                        print("401 오류: 액세스 토큰 재발급 실행")
                        throw URLError(.clientCertificateRejected)
                    default:
                        print("응답 코드: \(response)")
                    }
                }
                
                return data
            }
            .tryCatch{ error in
                guard !self.isAlreadyRequesting else {
                    print("이미 액세스 토큰 재발급 시도 중")
                    throw error
                }
                
                self.isAlreadyRequesting = true
                
                return self.reissueAccessToken()
                    .handleEvents(receiveOutput: { data in
                        self.isAlreadyRequesting = false
                        
                        if let decodedData = try? JSONDecoder().decode(AccessTokenModel.self, from: data) {
                            Keychain().create(key: "ACCESS_TOKEN", value: decodedData.accessToken)
                            Keychain().create(key: "ACCESS_TOKEN_EXPIRE_TIME", value: decodedData.accessTokenExpireTime)
                        } else {
                            print("Token Decoding Error")
                        }
                    })
                    .flatMap { _ in
                        self.urlSession(req: req)
                    }
            }
            .retry(1)
            .eraseToAnyPublisher()
    }
    
    // 액세스 토큰 재발급
    func reissueAccessToken() -> AnyPublisher<Data, Error> {
        if !self.checkRefreshTokenValid() {
            print("REFRESH_TOKEN이 유효하지 않음")
            return Fail(error: URLError(.clientCertificateRequired)).eraseToAnyPublisher()
        }
        
        guard let refreshToken = Keychain().read(key: "REFRESH_TOKEN") else {
            print("토큰 정보가 유효하지 않음")
            return Fail(error: URLError(.clientCertificateRequired)).eraseToAnyPublisher()
        }
        
        let url = URL(string: "\(ip)/token/access-token/issue")!
        
        // Header 세팅
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(refreshToken)", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap() { data, response in
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                    print("응답 코드: \(response)")
                }
                
                return data
            }
            .retry(1)
            .eraseToAnyPublisher()
    }
}
