//
//  AnswerTextBoxModel.swift
//  CHEEK
//
//  Created by 김태은 on 6/29/24.
//

import SwiftUI

struct AnswerStackModel: Identifiable {
    var id = UUID().uuidString
    
    // type
    var type: String
    
    // text
    var text: String = ""
    var isBold: Bool = false
    var textColor: Color = .white
    var fontSize: CGFloat = 15.0
    
    // others
    var view: AnyView?
    
    // offset
    var offset: CGSize = .zero
    var lastOffset: CGSize = .zero
    
    // scale
    var scale: CGFloat = 1
    var lastScale: CGFloat = 1
    
    // rotation
    var rotation: Angle = .zero
    var lastRotation: Angle = .zero
}
