//
//  ProfileStoriesView.swift
//  CHEEK
//
//  Created by 김태은 on 8/27/24.
//

import SwiftUI

struct ProfileStoriesView: View {
    var gridColumns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 4), count: 3)
    
    var body: some View {
        VStack(spacing: 0) {
            LazyVGrid(columns: gridColumns) {
                Rectangle()
                    .frame(height: 156)
                    .foregroundColor(.cheekMainNormal)
                
                Rectangle()
                    .frame(height: 156)
                    .foregroundColor(.cheekMainNormal)
            
            
                Rectangle()
                    .frame(height: 156)
                    .foregroundColor(.cheekMainNormal)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.cheekBackgroundTeritory)
    }
}

#Preview {
    ProfileStoriesView()
}
