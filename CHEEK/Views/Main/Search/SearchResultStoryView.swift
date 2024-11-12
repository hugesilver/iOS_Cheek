//
//  SearResultStoryView.swift
//  CHEEK
//
//  Created by 김태은 on 10/21/24.
//

import SwiftUI
import Kingfisher

fileprivate let vGridSpacing: CGFloat = 4

struct SearchResultStoryView: View {
    @ObservedObject var searchViewModel: SearchViewModel
    
    @Binding var isStoryOpen: Bool
    @Binding var selectedStories: [Int64]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 3), spacing: 4) {
                ForEach(searchViewModel.searchResult!.storyDto) { story in
                    ZStack(alignment: .leading) {
                        KFImage(URL(string: story.storyPicture))
                            .placeholder {
                                Color.cheekLineAlternative
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
                            .frame(
                                width: (UIScreen.main.bounds.width / 3) - (vGridSpacing / 2),
                                height: 156
                            )
                            .clipped()
                        
                        VStack {
                            Spacer()
                            
                            Text(Utils().convertToKST(dateString: story.modifiedAt)!)
                                .caption1(font: "SUIT", color: .cheekWhite, bold: true)
                                .frame(alignment: .bottomLeading)
                                .padding(8)
                        }
                    }
                    .contentShape(Rectangle())
                    .frame(height: 156)
                    .onTapGesture {
                        selectedStories = [story.storyId]
                        isStoryOpen = true
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.cheekBackgroundTeritory)
    }
}

#Preview {
    SearchResultStoryView(searchViewModel: SearchViewModel(), isStoryOpen: .constant(false), selectedStories: .constant([]))
}
