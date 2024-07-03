//
//  AnswerCanvasView.swift
//  CHEEK
//
//  Created by 김태은 on 7/4/24.
//

import SwiftUI
import PencilKit

struct AnswerCanvasView: UIViewRepresentable {
    @ObservedObject var viewModel: AddAnswerViewModel
    
    var ink: PKInkingTool {
        PKInkingTool(.pen, color: UIColor(viewModel.inkColor), width: viewModel.inkWidth)
    }
    
    var eraser: PKEraserTool {
        PKEraserTool(.bitmap)
    }
    
    func makeUIView(context: Context) -> PKCanvasView {
        let canvas: PKCanvasView = viewModel.canvas
        
        canvas.isOpaque = false
        canvas.backgroundColor = .clear
        canvas.drawingPolicy = .anyInput
        canvas.tool = viewModel.isDraw ? ink : eraser
        
        return canvas
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.tool = viewModel.isDraw ? ink : eraser
    }
}

#Preview {
    AnswerCanvasView(viewModel: AddAnswerViewModel())
}
