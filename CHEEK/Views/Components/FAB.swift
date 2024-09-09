//
//  FAB.swift
//  CHEEK
//
//  Created by 김태은 on 8/18/24.
//

import SwiftUI

struct FAB: View {
    var body: some View {
        Image("IconTalkFAB")
            .foregroundColor(.cheekWhite)
            .frame(width: 32)
            .padding(.horizontal, 24)
            .padding(.top, 27)
            .padding(.bottom, 24)
            .background(
                Circle()
                    .fill(.cheekMainHeavy)
                    .shadow(color: .black.opacity(0.25), radius: 2.5, x: 0, y: 0)
            )
    }
}

#Preview {
    FAB()
}
