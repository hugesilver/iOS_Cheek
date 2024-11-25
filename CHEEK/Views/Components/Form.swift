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
    
    let isReqired: Bool
    
    @Binding var text: String
    @Binding var information: String
    @Binding var status: statuses
    @FocusState.Binding var isFocused: Bool
    
    var showHelp: Bool = false
    var onTapHelp: () -> Void = {}
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if name != "" {
                HStack(spacing: 0) {
                    Text(name)
                        .body1(font: "SUIT", color: .cheekTextNormal, bold: true)
                    
                    if isReqired {
                        Text(" *")
                            .body1(font: "SUIT", color: .cheekStatusAlert, bold: true)
                    }
                    
                    if showHelp {
                        Button(action: {
                            onTapHelp()
                        }) {
                            Image("IconHelp")
                                .resizable()
                                .frame(width: 14, height: 14)
                                .foregroundColor(.cheekTextAlternative)
                        }
                        .padding(.leading, 8)
                    }
                }
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

struct TextEditorForm: View {
    enum statuses {
        case normal, focused, disabled, correct, wrong
    }
    
    let height: CGFloat
    
    var name: String
    var placeholder: String
    var keyboardType: UIKeyboardType?
    
    let isReqired: Bool
    
    @Binding var text: String
    @Binding var information: String
    @Binding var status: statuses
    @FocusState.Binding var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if name != "" {
                HStack(spacing: 0) {
                    Text(name)
                        .body1(font: "SUIT", color: .cheekTextNormal, bold: true)
                    
                    if isReqired {
                        Text(" *")
                            .body1(font: "SUIT", color: .cheekStatusAlert, bold: true)
                    }
                }
            }
            
            ZStack(alignment: .topLeading) {
                TextEditor(text: $text)
                    .scrollContentBackground(.hidden)
                
                if text.isEmpty && status != .focused {
                    Text(placeholder)
                        .foregroundColor(.cheekTextAlternative)
                }
            }
            .tint(.cheekMainNormal)
            .keyboardType(keyboardType ?? .default)
            .disabled(status == .disabled)
            .padding(.horizontal, 12)
            .padding(.vertical, 16)
            .body1(
                font: "SUIT",
                color: status == .disabled ? .cheekTextAlternative : .cheekTextStrong,
                bold: false)
            .focused($isFocused)
            .frame(height: height)
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
