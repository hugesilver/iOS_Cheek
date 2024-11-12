//
//  Alert.swift
//  CHEEK
//
//  Created by 김태은 on 11/10/24.
//

import SwiftUI

struct CustomAlert: View {
    @Binding var showAlert: Bool
    
    let title: String
    let buttonText: String
    
    var onTap: () -> Void
    
    var body: some View {
        VStack {
            VStack(spacing: 25) {
                Text(title)
                    .title1(font: "SUIT", color: .cheekTextStrong, bold: true)
                
                ButtonActive(text: buttonText)
                    .onTapGesture {
                        onTap()
                        showAlert = false
                    }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 32)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.cheekWhite)
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
        .background(.black.opacity(0.4))
        .ignoresSafeArea()
    }
}
