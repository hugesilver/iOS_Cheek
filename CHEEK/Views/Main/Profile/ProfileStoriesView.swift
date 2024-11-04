//
//  ProfileStoriesView.swift
//  CHEEK
//
//  Created by 김태은 on 8/27/24.
//

import SwiftUI

fileprivate let vGridSpacing: CGFloat = 4

struct ProfileStoriesView: View {
    @Binding var isStoryOpen: Bool
    @Binding var selectedStories: [Int64]
    var stories: [StoryDto]
    
    var gridColumns: [GridItem] = Array(repeating: .init(.flexible(), spacing: vGridSpacing), count: 3)
    
    var body: some View {
        VStack(spacing: 0) {
            LazyVGrid(columns: gridColumns) {
                ForEach(stories) { story in
                    AsyncImage(url: URL(string: story.storyPicture)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(
                                width: (UIScreen.main.bounds.width / 3) - (vGridSpacing / 2),
                                height: 156
                            )
                            .clipped()
                    } placeholder: {
                        Color.cheekMainNormal
                            .frame(
                                width: (UIScreen.main.bounds.width / 3) - (vGridSpacing / 2),
                                height: 156
                            )
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedStories = [story.storyId]
                        isStoryOpen = true
                    }
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.cheekBackgroundTeritory)
    }
}

#Preview {
    ProfileStoriesView(isStoryOpen: .constant(false), selectedStories: .constant([]), stories: [])
}
