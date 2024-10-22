//
//  FeedView.swift
//  CHEEK
//
//  Created by 김태은 on 6/13/24.
//

import SwiftUI

struct FeedView: View {
    @ObservedObject var profileViewModel: ProfileViewModel
    
    @Binding var selectedCategory: Int64
    
    @State var selectedTab: Int = 0
    @StateObject var viewModel: FeedViewModel = FeedViewModel()
    
    @State var isStoryOpen: Bool = false
    @State var selectedStories: [Int64] = []
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack {
                    Menu {
                        Picker(selection: $selectedCategory, label: EmptyView(), content: {
                            ForEach(CategoryModels().categories) { category in
                                Text(category.name)
                                    .tag(category.id)
                            }
                        })
                    } label: {
                        HStack(spacing: 4) {
                            Text(CategoryModels().categories[Int(selectedCategory) - 1].name)
                                .headline1(font: "SUIT", color: .cheekTextStrong, bold: true)
                            
                            Image("IconChevronDown")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.cheekTextStrong)
                        }
                    }
                    
                    Spacer()
                    
                    NavigationLink(destination: SearchView(profileViewModel: profileViewModel, catetory: CategoryModels().categories[Int(selectedCategory) - 1].id)) {
                        Image("IconSearch")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .padding(8)
                            .foregroundColor(.cheekTextNormal)
                    }
                }
                .padding(.top, 8)
                .padding(.horizontal, 16)
                
                TabsText(tabs: ["최신순", "인기순"], selectedTab: $selectedTab)
                    .padding(.top, 16)
                
                TabView(selection: $selectedTab) {
                    FeedNewestView(profileViewModel: profileViewModel, feedViewModel: viewModel, isStoryOpen: $isStoryOpen, selectedStories: $selectedStories, onRefresh: { getFeed() })
                        .tag(0)
                    
                    FeedPopularityView(profileViewModel: profileViewModel, feedViewModel: viewModel, isStoryOpen: $isStoryOpen, selectedStories: $selectedStories, onRefresh: { getFeed() })
                        .tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .background(.cheekBackgroundTeritory)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    NavigationLink(destination: AddQuestionView(profileViewModel: profileViewModel, categoryId: selectedCategory)) {
                        FAB()
                    }
                }
                .padding(24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            getFeed()
        }
        .onChange(of: selectedCategory) { _ in
            getFeed()
        }
        .fullScreenCover(isPresented: $isStoryOpen) {
            if #available(iOS 16.4, *) {
                StoryView(storyIds: $selectedStories, profileViewModel: profileViewModel)
                    .presentationBackground(.clear)
            } else {
                StoryView(storyIds: $selectedStories, profileViewModel: profileViewModel)
            }
        }
    }
    
    func getFeed() {
        guard let myId = profileViewModel.profile?.memberId else {
            print("profileViewModel에 profile이 없음")
            return
        }
        
        viewModel.getFeed(categoryId: selectedCategory, myId: myId)
    }
}

#Preview {
    FeedView(profileViewModel: ProfileViewModel(), selectedCategory: .constant(0))
}