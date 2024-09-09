//
//  AddAnswerViewModel.swift
//  CHEEK
//
//  Created by 김태은 on 6/27/24.
//

import SwiftUI
import PencilKit

class AddAnswerViewModel: ObservableObject {
    // 메뉴 상태
    enum UserInteractState {
        case draw, text, image, backgroundColor, save
    }
    
    // 선택한 메뉴 상태
    @Published var userInteractState: UserInteractState = .draw
    
    // 캔버스 초기화
    @Published var canvas = PKCanvasView()
    
    // 펜 설정
    @Published var isDraw: Bool = true
    @Published var inkWidth: CGFloat = 0
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
    func saveCanvasImage<Content: View>(@ViewBuilder content: @escaping ()->Content) {
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
                writeToAlbum(image: resizedImage)
            }
        }
    }
    
    // 앨범에 저장(임시)
    func writeToAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
    }
}
