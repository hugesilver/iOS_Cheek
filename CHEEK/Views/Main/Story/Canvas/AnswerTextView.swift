//
//  AnswerTextView.swift
//  CHEEK
//
//  Created by 김태은 on 7/4/24.
//

import SwiftUI

struct AnswerTextView: View {
    @ObservedObject var viewModel: AddAnswerViewModel
    var object: AnswerStackModel
    
    var body: some View {
        Text(viewModel.stackItems[viewModel.currentIndex].id == object.id && (viewModel.addTextObject || viewModel.editTextObject) ? "" : object.text)
            .label1(font: "SUIT", color: .cheekWhite, bold: true)
            .multilineTextAlignment(.center)
            .padding(viewModel.stackItems[viewModel.currentIndex].id == object.id && (viewModel.addTextObject || viewModel.editTextObject) ? 0 : 16)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(.cheekBlack.opacity(0.6))
            )
            .offset(object.offset)
            .scaleEffect(object.scale < 0.4 ? 0.4 : object.scale)
            .rotationEffect(object.rotation)
            .onTapGesture {
                viewModel.currentIndex = getIndex(stackItem: object)
                viewModel.tempTextObject = object
                
                viewModel.editTextObject = true
            }
            .onLongPressGesture(minimumDuration: 0.2) {
                deleteObject(stackItem: object)
            }
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
    
    func deleteObject(stackItem: AnswerStackModel) {
        let currentIndex = getIndex(stackItem: stackItem)
        
        viewModel.currentIndex = 0
        viewModel.stackItems.remove(at: currentIndex)
        
    }
}

/*
#Preview {
    AnswerTextView()
}
*/
