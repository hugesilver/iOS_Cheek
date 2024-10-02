//
//  Publishers.swift
//  CHEEK
//
//  Created by 김태은 on 10/1/24.
//

import Foundation
import Combine

class CombinePublishers: ObservableObject {
    private var cancellable: AnyCancellable?
    
    func urlSessionToString(req: URLRequest) -> AnyPublisher<String, Error> {
        // combine urlsession
        guard let accessToken: String = Keychain().read(key: "ACCESS_TOKEN") else {
            print("ACCESS_TOKEN 불러오기 실패")
            return Fail(error: URLError(.clientCertificateRejected)).eraseToAnyPublisher()
        }
        
        var request: URLRequest = req
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap() { data, response in
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                    print("응답 코드: \(response)")
                }
                
                if let dataString = String(data: data, encoding: .utf8) {
                    return dataString
                } else {
                    print("data를 String으로 변환 중 오류 발생")
                    throw URLError(.cannotDecodeContentData)
                }
            }
            .retry(1)
            .eraseToAnyPublisher()
    }
}
