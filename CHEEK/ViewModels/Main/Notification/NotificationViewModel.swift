//
//  NotificationViewModel.swift
//  CHEEK
//
//  Created by 김태은 on 10/28/24.
//

import Foundation
import Combine
import FirebaseMessaging

class NotificationViewModel: ObservableObject {
    private let ip = Bundle.main.object(forInfoDictionaryKey: "SERVER_IP") as! String
    private var cancellables = Set<AnyCancellable>()
    
    @Published var notifications: [NotificationModel] = []
    @Published var readNotifications: Set<Int64> = []
    
    // 알림 준비 확인
    func isNotificationEnabledAndFCMReady() {
        // 앱 알림 설정 여부(리팩토링 필요)
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                // 앱 알림 허용한 경우
                if settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional {
                    // FCM 토큰 불러오기
                    let prevToken = Keychain().read(key: "PREV_FCM_TOKEN")
                    guard let token = Keychain().read(key: "FCM_TOKEN") else { return }
                    
                    if prevToken != token {
                        self.setFCMToken(token: token)
                        Keychain().create(key: "PREV_FCM_TOKEN", value: token)
                    }
                }
            }
        }
    }
    
    // FCM 토큰 전송
    func setFCMToken(token: String) {
        let url = URL(string: "\(ip)/noti/token")!
        
        // Header 세팅
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Body 세팅
        let bodyData: [String: Any] = [
            "firebaseToken": token
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: bodyData, options: [])
        } catch {
            print("FCM 토큰 Body JSON 변환 중 오류: \(error)")
            return
        }
        
        CombinePublishers().urlSession(req: request)
            .sink(receiveCompletion: { isComplete in
                switch isComplete {
                case .finished:
                    print("setFCMToken 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("setFCMToken 함수 실행 중 요청 실패: \(error)")
                }
            }, receiveValue: { data in
                let dataString = String(data: data, encoding: .utf8)
                
                print("FCM 토큰 보내기: \(dataString == "ok")")
            })
            .store(in: &cancellables)
    }
    
    // 알림 불러오기
    func getNotifications() {
        let url = URL(string: "\(ip)/noti")!
        
        // Header 세팅
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        CombinePublishers().urlSession(req: request)
            .decode(type: [NotificationModel].self, decoder: JSONDecoder())
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("getNotifications 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("getNotifications 함수 실행 중 요청 실패: \(error)")
                }
            }, receiveValue: { data in
                DispatchQueue.main.async {
                    self.notifications = data
                }
            })
            .store(in: &cancellables)
    }
    
    // 알림 단일 삭제
    func deleteOneNotification(notificationId: Int64) {
        let url = URL(string: "\(ip)/noti/\(notificationId)")!
        
        // Header 세팅
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        CombinePublishers().urlSession(req: request)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("deleteOneNotification 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("deleteOneNotification 함수 실행 중 요청 실패: \(error)")
                }
            }, receiveValue: { data in
                let dataString = String(data: data, encoding: .utf8)
                
                if dataString == "ok" {
                    DispatchQueue.main.async {
                        self.notifications = self.notifications.filter { $0.notificationId != notificationId }
                    }
                }
            })
            .store(in: &cancellables)
    }
    
    // 알림 모두 삭제
    func deleteAllNotifications() {
        let url = URL(string: "\(ip)/noti")!
        
        // Header 세팅
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        CombinePublishers().urlSession(req: request)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("deleteAllNotifications 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("deleteAllNotifications 함수 실행 중 요청 실패: \(error)")
                }
            }, receiveValue: { data in
                let dataString = String(data: data, encoding: .utf8)
                
                if dataString == "ok" {
                    DispatchQueue.main.async {
                        self.notifications.removeAll()
                    }
                }
            })
            .store(in: &cancellables)
    }
    
    // 읽은 알림ID 불러오기
    func getReadNotifications() {
        readNotifications = Set(UserDefaults.standard.array(forKey: "readNotifications") as? [Int64] ?? [])
    }
    
    // 알림 읽음 로직
    func setReadNotifications(notificationId: Int64) {
        if !readNotifications.contains(notificationId) {
            readNotifications.insert(notificationId)
            UserDefaults.standard.set(Array(readNotifications), forKey: "readNotifications")
        }
    }
    
    // 알림 모두 읽음
    func readAllNotifications() {
        readNotifications.removeAll()
        UserDefaults.standard.set(notifications.map{ $0.notificationId } , forKey: "readNotifications")
    }
}
