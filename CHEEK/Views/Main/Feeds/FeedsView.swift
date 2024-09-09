//
//  FeedView.swift
//  CHEEK
//
//  Created by 김태은 on 6/13/24.
//

import SwiftUI

struct FeedsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var categories: [CategoryModel]
    
    @Binding var selectedCategory: Int
    
    @State var selectedTab: Int = 0
    
    var body: some View {
        NavigationStack {
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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.cheekBackgroundTeritory)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
}

#Preview {
    FeedsView(categories: [
        CategoryModel(id: 0, image: "IconJobDevelop", name: "개발"),
        CategoryModel(id: 1, image: "IconJobManage", name: "기획"),
        CategoryModel(id: 2, image: "IconJobDesign", name: "디자인"),
        CategoryModel(id: 3, image: "IconJobFinance", name: "재무/회계"),
        CategoryModel(id: 4, image: "IconJobSales", name: "영업"),
        CategoryModel(id: 5, image: "IconJobMed", name: "의료"),
        CategoryModel(id: 6, image: "IconJobEdu", name: "교육"),
        CategoryModel(id: 7, image: "IconJobLaw", name: "법"),
    ], selectedCategory: .constant(0))
}
