//
//  Category.swift
//  CHEEK
//
//  Created by 김태은 on 8/26/24.
//

import SwiftUI

struct Category: View {
    var title: String
    var description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .headline1(font: "SUIT", color: .cheekTextNormal, bold: true)
            
            Text(description)
                .label1(font: "SUIT", color: .cheekTextAlternative, bold: false)
        }
    }
}
