//
//  AnswerQuestionView.swift
//  CHEEK
//
//  Created by 김태은 on 7/4/24.
//

import SwiftUI

struct AnswerQuestionView: View {
    @ObservedObject var viewModel: AddAnswerViewModel
    var object: AnswerStackModel
    
    var body: some View {
        object.view
            .rotationEffect(object.rotation) // offset 위에 두어야 반영
            .scaleEffect(object.scale < 0.75 ? 0.75 : object.scale) // offset 위에 두어야 반영
            .offset(object.offset)
            .gesture(
                DragGesture()
                    .onChanged{ value in
                        moveViewToFront(stackItem: object)
                        
                        let current = value.translation
                        
                        let lastOffset = object.lastOffset
                        let newTransition = CGSize(
                            width: lastOffset.width + current.width,
                            height: lastOffset.height + current.height
                        )
                        
                        viewModel.stackItems[getIndex(stackItem: object)].offset = newTransition
                    }
                    .onEnded{ value in
                        let current = value.translation
                        
                        let lastOffset = object.lastOffset
                        let newTransition = CGSize(
                            width: lastOffset.width + current.width,
                            height: lastOffset.height + current.height
                        )
                        
                        viewModel.stackItems[getIndex(stackItem: object)].lastOffset = newTransition
                    }
            )
            .gesture(
                MagnificationGesture()
                    .onChanged{ value in
                        viewModel.stackItems[getIndex(stackItem: object)].scale = viewModel.stackItems[getIndex(stackItem: object)].lastScale + (value - 1)
                    }
                    .onEnded{ value in
                        viewModel.stackItems[getIndex(stackItem: object)].lastScale = viewModel.stackItems[getIndex(stackItem: object)].scale
                    }
                    .simultaneously(
                        with: RotationGesture()
                            .onChanged{ value in
                                viewModel.stackItems[getIndex(stackItem: object)].rotation = viewModel.stackItems[getIndex(stackItem: object)].lastRotation + value
                            }
                            .onEnded{ value in
                                viewModel.stackItems[getIndex(stackItem: object)].lastRotation = viewModel.stackItems[getIndex(stackItem: object)].rotation
                            }
                    )
            )
    }
    
    func getIndex(stackItem: AnswerStackModel) -> Int {
        let index = viewModel.stackItems.firstIndex { (box) -> Bool in
            return stackItem.id == box.id
        } ?? 0
        
        return index
    }
    
    func moveViewToFront(stackItem: AnswerStackModel) {
        let currentIndex = getIndex(stackItem: stackItem)
        viewModel.currentIndex = currentIndex
        
        let lastIndex = viewModel.stackItems.count - 1
        
        viewModel.stackItems.insert(viewModel.stackItems.remove(at: currentIndex), at: lastIndex)
        
        viewModel.currentIndex = lastIndex
    }
}

struct AnswerQuestionBlock: View {
    var data: QuestionModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                ProfileXS(url: data.memberDto.profilePicture)
                
                Text(data.memberDto.nickname ?? "알 수 없는 사용자")
                    .body2(font: "SUIT", color: .cheekTextStrong, bold: true)
                
                Spacer()
            }
            
            Text(data.content)
                .label2(font: "SUIT", color: .cheekTextStrong, bold: false)
                .multilineTextAlignment(.leading)
        }
        .padding(16)
        .frame(maxWidth: 240)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .foregroundColor(.cheekWhite)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.cheekTextAlternative, lineWidth: 1)
                )
            
        )
    }
}

/*
#Preview {
    AnswerQuestionView()
}
*/
