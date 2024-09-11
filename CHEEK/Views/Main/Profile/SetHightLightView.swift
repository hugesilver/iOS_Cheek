//
//  SelectStoriesView.swift
//  CHEEK
//
//  Created by 김태은 on 9/4/24.
//

import SwiftUI

struct SetHighlightView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var categoriesColumns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 4), count: 3)
    
    @State var selectedStories: [String] = []
    @State var stories: [String] = ["1", "2", "3", "4"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    Image("IconChevronLeft")
                        .foregroundColor(.cheekTextNormal)
                        .frame(width: 32, height: 32)
                        .onTapGesture {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .padding(8)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Text("완료")
                            .label1(font: "SUIT", color: .cheekTextNormal, bold: false)
                        
                        if selectedStories.count > 0 {
                            Text("\(selectedStories.count)")
                                .label1(font: "SUIT", color: .cheekMainStrong, bold: true)
                        }
                    }
                    .padding(.horizontal, 11)
                }
                .overlay(
                    Text("스토리 선택")
                        .title1(font: "SUIT", color: .cheekTextNormal, bold: true)
                    , alignment: .center
                )
                .padding(.top, 8)
                .padding(.horizontal, 16)
                
                ScrollView(.horizontal) {
                    HStack(spacing: 8) {
                        ForEach(selectedStories, id: \.self) { story in
                            AsyncImage(url: URL(string: story)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } placeholder: {
                                Color.cheekLineAlternative
                            }
                            .aspectRatio(9 / 16, contentMode: .fit)
                            .frame(width: 159)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        
                        RoundedRectangle(cornerRadius: 16)
                            .foregroundColor(.cheekLineAlternative)
                            .aspectRatio(9 / 16, contentMode: .fit)
                            .frame(width: 159)
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.top, 17)
                
                ScrollView {
                    LazyVGrid(columns: categoriesColumns, spacing: 4) {
                        ForEach(stories, id: \.self) { story in
                            ZStack(alignment: .leading) {
                                AsyncImage(url: URL(string: story)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                } placeholder: {
                                    Color.cheekLineAlternative
                                }
                                
                                if selectedStories.contains(story) {
                                    Rectangle()
                                        .foregroundColor(.cheekMainNormal.opacity(0.2))
                                        .overlay(
                                            Rectangle()
                                                .strokeBorder(.cheekMainNormal, lineWidth: 2)
                                        )
                                }
                                
                                VStack {
                                    if selectedStories.contains(story) {
                                        Circle()
                                            .frame(width: 24, height: 24)
                                            .foregroundColor(.cheekMainNormal)
                                            .overlay(
                                                Image("IconCheck")
                                                    .resizable()
                                                    .frame(width: 16, height: 16)
                                                    .foregroundColor(.cheekTextNormal)
                                            )
                                            .padding(8)
                                    } else {
                                        Circle()
                                            .foregroundColor(Color(red: 0.29, green: 0.29, blue: 0.29).opacity(0.6))
                                            .frame(width: 24, height: 24)
                                            .overlay(
                                                Circle()
                                                    .strokeBorder(.cheekWhite, lineWidth: 2)
                                            )
                                            .padding(8)
                                    }
                                    
                                    Spacer()
                                }
                                
                                VStack {
                                    Spacer()
                                    
                                    Text("2024-12-31")
                                        .caption1(font: "SUIT", color: .cheekWhite, bold: true)
                                        .frame(alignment: .bottomLeading)
                                        .padding(8)
                                }
                            }
                            .aspectRatio(9 / 16, contentMode: .fit)
                            .onTapGesture {
                                if let index = selectedStories.firstIndex(of: story) {
                                    selectedStories.remove(at: index)
                                } else {
                                    selectedStories.append(story)
                                }
                            }
                        }
                    }
                }
                .padding(.top, 27)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
}


#Preview {
    SetHighlightView()
}
