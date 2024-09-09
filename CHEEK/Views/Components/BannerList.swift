//
//  BannerList.swift
//  CHEEK
//
//  Created by 김태은 on 8/18/24.
//

import SwiftUI

struct BannerList: View {
    var currentIndex: Int
    var maxLength: Int
    
    var body: some View {
        Text("\(currentIndex) / \(maxLength)")
            .label2(font: "SUIT", color: .cheekBackgroundTeritory, bold: false)
            .kerning(0.07)
            .multilineTextAlignment(.center)
            .foregroundColor(.cheekWhite)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        Color(red: 0.29, green: 0.29, blue: 0.29).opacity(0.6))
            )
    }
}

#Preview {
    BannerList(currentIndex: 1, maxLength: 10)
}
