//
//  SelectableCard.swift
//  CHEEK
//
//  Created by 김태은 on 7/31/24.
//

import SwiftUI

struct SelectableCard: View {
    var isSelect: Bool
    
    var title: String
    var description: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .title1(font: "SUIT", color: .cheekTextNormal, bold: true)
            .multilineTextAlignment(.center)
            
            Text(description)
                .body1(font: "SUIT", color: .cheekTextNormal, bold: false)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .stroke(isSelect ? .cheekMainStrong : .cheekTextAssitive, lineWidth: 1)
                .background(isSelect ? .cheekMainNormal.opacity(0.2) : .cheekWhite
                )
        )
    }
}

#Preview {
    SelectableCard(isSelect: true, title: "test", description: "test")
}
