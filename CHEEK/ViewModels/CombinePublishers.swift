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
    
    func urlSession(req: URLRequest) -> AnyPublisher<Data, Error> {
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
                
                // 디버깅
                if let dataString = String(data: data, encoding: .utf8) {
                    print(dataString)
                }
                
                return data
            }
            .retry(1)
            .eraseToAnyPublisher()
    }
}
