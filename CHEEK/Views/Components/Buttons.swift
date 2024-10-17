//
//  Buttons.swift
//  CHEEK
//
//  Created by 김태은 on 7/31/24.
//

import SwiftUI

struct ButtonActive: View {
    var text: String
    
    var body: some View {
        Text(text)
            .label1(font: "SUIT", color: .cheekTextNormal, bold: true)
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.cheekMainStrong)
            )
    }
}

struct ButtonDisabled: View {
    var text: String
    
    var body: some View {
        Text(text)
            .label1(font: "SUIT", color: .cheekTextAlternative, bold: true)
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.cheekLineNormal)
            )
    }
}

struct ButtonLine: View {
    var text: String
    
    var body: some View {
        Text(text)
            .label1(font: "SUIT", color: .cheekTextAlternative, bold: true)
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.cheekTextAssitive, lineWidth: 1)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.cheekWhite)
                    )
                
            )
    }
}

struct ButtonHugActive: View {
    var text: String
    
    var body: some View {
        Text(text)
            .label1(font: "SUIT", color: .cheekTextNormal, bold: true)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.cheekMainStrong)
            )
    }
}

struct ButtonHugDisabled: View {
    var text: String
    
    var body: some View {
        Text(text)
            .label1(font: "SUIT", color: .cheekTextNormal, bold: true)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.cheekLineNormal)
            )
    }
}

struct ButtonNarrowFill: View {
    var text: String
    
    var body: some View {
        Text(text)
            .label1(font: "SUIT", color: .cheekTextNormal, bold: true)
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.cheekMainNormal)
            )
    }
}

struct ButtonNarrowHug: View {
    var text: String
    
    var body: some View {
        Text(text)
            .label1(font: "SUIT", color: .cheekTextNormal, bold: true)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.cheekMainNormal)
            )
    }
}

struct ButtonNarrowDisabled: View {
    var text: String
    
    var body: some View {
        Text(text)
            .label1(font: "SUIT", color: .cheekTextNormal, bold: true)
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.cheekTextAssitive)
            )
    }
}

struct ButtonNarrowLine: View {
    var text: String
    
    var body: some View {
        Text(text)
            .label1(font: "SUIT", color: .cheekTextAlternative, bold: true)
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.cheekTextAssitive, lineWidth: 1)
                    .foregroundColor(.cheekWhite)
            )
    }
}

/*
 #Preview {
 ButtonNarrowHug(text: "test")
 }
 */
