//
//  Ranking.swift
//  CHEEK
//
//  Created by 김태은 on 8/18/24.
//

import SwiftUI

struct Ranking: View {
    var rank: Int
     
    var body: some View {
        Circle()
            .fill(rank == 1 ? Color(red: 1, green: 0.6, blue: 0) : .cheekTextAssitive)
            .frame(width: 24, height: 24)
            .overlay(
                Text("\(rank)")
                    .font(.custom("SUIT", size: 12))
                    .foregroundColor(.cheekWhite)
                    .fontWeight(.black)
            )
    }
}
