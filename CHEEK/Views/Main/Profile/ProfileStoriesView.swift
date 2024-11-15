//
//  ProfileStoriesView.swift
//  CHEEK
//
//  Created by 김태은 on 8/27/24.
//

import SwiftUI
import Kingfisher

fileprivate let LAZY_V_GRID_SPACING: CGFloat = 4

struct ProfileStoriesView: View {
    @Binding var isStoryOpen: Bool
    @Binding var selectedStories: [Int64]
    var stories: [StoryDto]
    
    var body: some View {
        VStack(spacing: 0) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: LAZY_V_GRID_SPACING), count: 3)) {
                ForEach(stories) { story in
                    KFImage(URL(string: story.storyPicture))
                        .placeholder {
                            Color.cheekMainNormal
                        }
                        .retry(maxCount: 2, interval: .seconds(2))
                        .onSuccess { result in
                            
                        }
                        .onFailure { error in
                            print("이미지 불러오기 실패: \(error)")
                        }
                        .resizable()
                        .cancelOnDisappear(true)
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 156)
                        .frame(maxWidth: .infinity)
                        .clipped()
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
