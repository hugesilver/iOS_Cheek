//
//  Chip.swift
//  CHEEK
//
//  Created by 김태은 on 8/18/24.
//

import SwiftUI

struct ChipDefault: View {
    var text: String
    
    var body: some View {
        Text(text)
            .label1(font: "SUIT", color: .cheekTextStrong, bold: false)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(.cheekBackgroundTeritory)
                    .overlay(
                        Capsule()
                        .inset(by: 0.5)
                        .stroke(.cheekTextAssitive, lineWidth: 1)
                    )
            )
    }
}

struct ChipSearch: View {
    var text: String
    var onTap: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(text)
                .label2(font: "SUIT", color: .cheekTextStrong, bold: false)
            
            Image("IconX")
                .resizable()
                .foregroundColor(.cheekTextStrong)
                .frame(width: 16, height: 16)
                .onTapGesture {
                    onTap()
                }
        }
        .padding(.leading, 10)
        .padding(.trailing, 8)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(.cheekBackgroundTeritory)
                .overlay(
                    Capsule()
                        .inset(by: 0.5)
                        .stroke(.cheekTextNormal, lineWidth: 1)
                )
        )
    }
}
