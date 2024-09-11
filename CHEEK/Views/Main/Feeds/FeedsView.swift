//
//  FeedView.swift
//  CHEEK
//
//  Created by 김태은 on 6/13/24.
//

import SwiftUI

struct FeedsView: View {
    @Binding var selectedCategory: Int
    @Binding var isPresented: Bool
    @Binding var path: MainView.PATHS
    
    var categories: [CategoryModel]
    
    @State var selectedTab: Int = 0
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Menu {
                        Picker(selection: $selectedCategory, label: EmptyView(), content: {
                            ForEach(categories) { category in
                                Text(category.name)
                                    .tag(category.id)
                            }
                        })
                    } label: {
                        HStack(spacing: 4) {
                            Text(categories[selectedCategory].name)
                                .headline1(font: "SUIT", color: .cheekTextStrong, bold: true)
                            
                            Image("IconChevronDown")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.cheekTextStrong)
                        }
                    }
                    
                    Spacer()
                    
                    Image("IconSearch")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .padding(8)
                        .foregroundColor(.cheekTextNormal)
                        .onTapGesture {
                            path = .search
                            isPresented = true
                        }
                }
                .padding(.top, 8)
                .padding(.horizontal, 16)
                
                TabsText(tabs: ["최신순", "인기순"], selectedTab: $selectedTab)
                    .padding(.top, 16)
                
                TabView(selection: $selectedTab) {
                    FeedsNewestView()
                        .tag(0)
                    
                    FeedsPopularityView()
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
                    
                    FAB()
                        .onTapGesture {
                            path = .question
                            isPresented = true
                        }
                }
                .padding(24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    FeedsView(
        selectedCategory: .constant(0),
        isPresented: .constant(false), path: .constant(.search),
        categories: [
            CategoryModel(id: 0, image: "IconJobDevelop", name: "개발"),
            CategoryModel(id: 1, image: "IconJobManage", name: "기획"),
            CategoryModel(id: 2, image: "IconJobDesign", name: "디자인"),
            CategoryModel(id: 3, image: "IconJobFinance", name: "재무/회계"),
            CategoryModel(id: 4, image: "IconJobSales", name: "영업"),
            CategoryModel(id: 5, image: "IconJobMed", name: "의료"),
            CategoryModel(id: 6, image: "IconJobEdu", name: "교육"),
            CategoryModel(id: 7, image: "IconJobLaw", name: "법"),
        ])
}
