//
//  SearResultStoryView.swift
//  CHEEK
//
//  Created by 김태은 on 10/21/24.
//

import SwiftUI

struct SearchResultStoryView: View {
    @ObservedObject var searchViewModel: SearchViewModel
    
    @Binding var isStoryOpen: Bool
    @Binding var selectedStories: [Int64]
    
    var storyColumns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 4), count: 3)
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: storyColumns, spacing: 4) {
                ForEach(searchViewModel.searchResult!.storyDto) { story in
                    ZStack(alignment: .leading) {
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
                            Color.cheekLineAlternative
                        }
                        
                        VStack {
                            Spacer()
                            
                            Text(Utils().convertToKST(from: story.modifiedAt)!)
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
