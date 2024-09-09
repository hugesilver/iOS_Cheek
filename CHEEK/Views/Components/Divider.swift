//
//  Divider.swift
//  CHEEK
//
//  Created by 김태은 on 8/18/24.
//

import SwiftUI


struct DividerLarge: View {
    var body: some View {
        Rectangle()
            .fill(.cheekLineNormal)
            .frame(maxWidth: .infinity)
            .frame(height: 4)
    }
}

struct DividerSmall: View {
    var body: some View {
        Rectangle()
            .fill(.cheekLineNormal)
            .frame(maxWidth: .infinity)
            .frame(height: 1)
    }
}
