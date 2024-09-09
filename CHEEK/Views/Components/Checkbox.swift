//
//  Checkbox.swift
//  CHEEK
//
//  Created by 김태은 on 8/18/24.
//

import SwiftUI

struct Checkbox: View {
    var isSelect: Bool
    
    var body: some View {
        if isSelect {
            Circle()
                .fill(.cheekMainNormal)
                .frame(width: 20, height: 20)
                .overlay(
                    Image("IconCheck")
                        .frame(height: 8)
                        .tint(.cheekTextNormal)
                )
        } else {
            Circle()
                .fill(
                    Color(red: 0.29, green: 0.29, blue: 0.29)
                        .opacity(0.6)
                )
                .frame(width: 20, height: 20)
                .overlay(
                    Circle()
                        .inset(by: 1)
                        .stroke(.white, lineWidth: 2)
                )
        }
    }
    
}

#Preview {
    Checkbox(isSelect: true)
}
