//
//  AnswerDrawingView.swift
//  CHEEK
//
//  Created by 김태은 on 6/28/24.
//

import SwiftUI

struct AnswerDrawingView: View {
    @ObservedObject var viewModel: AddAnswerViewModel
    
    var body: some View {
        ZStack {
            // 캔버스
            AnswerCanvasView(viewModel: viewModel)
            
            // 스택 오브젝트
            ForEach(viewModel.stackItems) { object in
                if object.type == "text" {
                    AnswerTextView(
                        viewModel: viewModel,
                        object: object)
                } else if object.type == "image" {
                    AnswerImageView(
                        viewModel: viewModel,
                        object: object)
                } else if object.type == "question" {
                    AnswerQuestionView(
                        viewModel: viewModel,
                        object: object)
                }
            }
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .background(viewModel.frameBackgroundColor)
    }
}

#Preview {
    AnswerDrawingView(viewModel: AddAnswerViewModel())
}


