//
//  AddAnswerViewModel.swift
//  CHEEK
//
//  Created by 김태은 on 6/27/24.
//

import Foundation
import Combine
import SwiftUI
import PencilKit

class AddAnswerViewModel: ObservableObject {
    private let ip = Bundle.main.object(forInfoDictionaryKey: "SERVER_IP") as! String
    private var cancellables = Set<AnyCancellable>()
    
    // 로딩 중
    @Published var isLoading: Bool = false
    
    // 알림창
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    @Published var questionModel: QuestionModel? = nil
    
    // 메뉴 상태
    enum UserInteractState {
        case draw, text, image, backgroundColor, save
    }
    
    // 선택한 메뉴 상태
    @Published var userInteractState: UserInteractState = .save
    
    // 캔버스 초기화
    @Published var canvas = PKCanvasView()
    
    // 펜 설정
    @Published var isDraw: Bool = true
    @Published var inkType: PKInkingTool.InkType = .marker
    @Published var inkWidth: CGFloat = 20
    @Published var inkColor: Color = .black
    
    // 오브젝트 스택
    @Published var stackItems: [AnswerStackModel] = []
    
    // 현재 스택의 index
    @Published var currentIndex: Int = 0
    
    // 텍스트 추가 및 수정 상태
    @Published var addTextObject: Bool = false
    @Published var editTextObject: Bool = false
    
    // 임시 텍스트 오브젝트
    @Published var tempTextObject: AnswerStackModel = AnswerStackModel(type: "text")
    
    // 배경색
    @Published var frameBackgroundColor: Color = .cheekWhite
    
    // 거부됨
    func showError(message: String) {
        DispatchQueue.main.async {
            self.alertMessage = message
            self.showAlert = true
        }
    }
    
    func getQuestion(questionId: Int64) {
        isLoading = true
        print("질문 조회 시도")
        
        let url = URL(string: "\(ip)/question/\(questionId)")!
        
        // Header 세팅
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        CombinePublishers().urlSession(req: request)
            .decode(type: QuestionModel.self, decoder: JSONDecoder())
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("getQuestions 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("getQuestions 함수 실행 중 요청 실패: \(error)")
                    self.showError(message: "오류가 발생했습니다.")
                }
            }, receiveValue: { data in
                DispatchQueue.main.async {
                    self.questionModel = data
                    self.stackItems.append(
                        AnswerStackModel(
                            type: "question",
                            view: AnyView(AnswerQuestionBlock(data: data))
                        )
                    )
                    self.isLoading = false
                }
            })
            .store(in: &self.cancellables)
    }
    
    // 텍스트 추가 및 수정 닫기
    func cancelTextView() {
        canvas.becomeFirstResponder()
        
        if addTextObject {
            addTextObject = false
            
            stackItems.removeLast()
            currentIndex = stackItems.count - 1
        }
        
        if editTextObject {
            editTextObject = false
        }
    }
    
    // 이미지로 저장 중 safearea 부분 삭제
    func removeSafeArea() -> UIEdgeInsets {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .zero
        }
        
        guard let safeArea = screen.windows.first?.safeAreaInsets else {
            return .zero
        }
        
        return safeArea
    }
    
    // 이미지로 저장
    func saveCanvasImage<Content: View>(myId: Int64, @ViewBuilder content: @escaping () -> Content, completion: @escaping (Bool) -> Void) {
        isLoading = true
        
        let uiView = UIHostingController(rootView: content().padding(.top, -removeSafeArea().top))
        let frame = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width / 9 * 16))
        uiView.view.frame = frame
        
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 0)
        uiView.view.drawHierarchy(in: frame, afterScreenUpdates: true)
        
        let originalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let originalImage = originalImage {
            let width: CGFloat = 900
            let scaleFactor = width / originalImage.size.width
            let height = originalImage.size.height * scaleFactor
            let newFrame = CGSize(width: width, height: height)
            
            UIGraphicsBeginImageContextWithOptions(newFrame, false, 1)
            originalImage.draw(in: CGRect(origin: .zero, size: newFrame))
            
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            if let resizedImage = resizedImage {
                uploadAnswerStory(myId: myId, storyPicture: resizedImage) { isSuccess in
                    completion(isSuccess)
                }
            } else {
                showError(message: "오류가 발생하였습니다.")
                completion(false)
            }
        } else {
            showError(message: "오류가 발생하였습니다.")
            completion(false)
        }
    }
    
    func uploadAnswerStory(myId: Int64, storyPicture: UIImage, completion: @escaping (Bool) -> Void) {
        guard questionModel != nil else {
            print("questionModel 없음")
            showError(message: "오류가 발생하였습니다.")
            return
        }
        
        let url = URL(string: "\(ip)/story")!
        
        // Boundary 설정
        let boundary = UUID().uuidString
        
        // Header 설정
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Body 설정
        var httpBody = Data()
        
        let texts = stackItems.filter{ $0.type == "text" }.map{ $0.text }.joined(separator: " ")
        
        // storyDto
        let storyDto: [String: Any] = [
            "categoryId": questionModel!.categoryId,
            "memberId": myId,
            "questionId": questionModel!.questionId,
            "text": texts
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: storyDto, options: .prettyPrinted) {
            httpBody.append("--\(boundary)\r\n".data(using: .utf8)!)
            httpBody.append("Content-Disposition: form-data; name=\"storyDto\"\r\n".data(using: .utf8)!)
            httpBody.append("Content-Type: application/json\r\n\r\n".data(using: .utf8)!)
            httpBody.append(jsonData)
            httpBody.append("\r\n".data(using: .utf8)!)
        }
        
        httpBody.append("--\(boundary)\r\n".data(using: .utf8)!)
        httpBody.append("Content-Disposition: form-data; name=\"storyPicture\"; filename=\"story.jpg\"\r\n".data(using: .utf8)!)
        httpBody.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        httpBody.append(storyPicture.jpegData(compressionQuality: 1.0)!)
        httpBody.append("\r\n".data(using: .utf8)!)
        
        // Boundary 끝 추가
        httpBody.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = httpBody
        
        CombinePublishers().urlSession(req: request)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("uploadAnswerStory 함수 실행 중 요청 성공")
                case .failure(let error):
                    print("uploadAnswerStory 함수 실행 중 요청 실패: \(error)")
                    self.showError(message: "오류가 발생했습니다.")
                }
            }, receiveValue: { data in
                let dataString = String(data: data, encoding: .utf8)
                completion(dataString == "ok")
            })
            .store(in: &self.cancellables)
    }
}
