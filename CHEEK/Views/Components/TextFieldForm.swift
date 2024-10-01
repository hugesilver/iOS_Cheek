//
//  TextFields.swift
//  CHEEK
//
//  Created by 김태은 on 7/31/24.
//

import SwiftUI

struct TextFieldForm: View {
    enum statuses {
        case normal, focused, disabled, correct, wrong
    }
    
    var name: String
    var placeholder: String
    var keyboardType: UIKeyboardType?
    
    @Binding var text: String
    @Binding var information: String
    @Binding var status: statuses
    @FocusState.Binding var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if name != "" {
                Text(name)
                    .body1(font: "SUIT", color: .cheekTextNormal, bold: true)
            }
            
            TextField(
                "",
                text: $text,
                prompt:
                    Text(verbatim: placeholder)
                    .foregroundColor(.cheekTextAlternative)
            )
            .tint(.cheekMainNormal)
            .keyboardType(keyboardType ?? .default)
            .disabled(status == .disabled)
            .body1(
                font: "SUIT",
                color: status == .disabled ? .cheekTextAlternative : .cheekTextStrong,
                bold: false)
            .focused($isFocused)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        textFieldborder(status: status), lineWidth: status == .normal || status == .disabled ? 1 : 2)
                    .background(status == .disabled ?
                        .cheekLineAlternative : .clear)
            )
            .onChange(of: isFocused) { _ in
                if isFocused {
                    status = .focused
                    information = ""
                }
            }
            
            if information != "" {
                Text(information)
                    .label2(
                        font: "SUIT",
                        color: status == .wrong ? .cheekStatusAlert :
                            status == .correct ? .cheekStatusPositive :
                                .cheekTextAlternative,
                        bold: true)
            }
        }
    }
    
    func textFieldborder(status: statuses) -> Color {
        switch status {
        case .normal:
            return .cheekTextAssitive
        case .disabled:
            return .cheekTextAssitive
        case .focused:
            return .cheekMainNormal
        case .wrong:
            return .cheekStatusAlert
        case .correct:
            return .cheekStatusPositive
        }
    }
}
