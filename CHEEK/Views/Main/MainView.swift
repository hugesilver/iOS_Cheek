//
//  MainView.swift
//  CHEEK
//
//  Created by 김태은 on 6/12/24.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var profileViewModel: ProfileViewModel
    
    // 탭 인덱스
    @State var currentIndex: Int = 0
    
    // 카테고리
    let categories: [CategoryModel] = [
        CategoryModel(id: 1, image: "IconJobDevelop", name: "개발"),
        CategoryModel(id: 2, image: "IconJobManage", name: "기획"),
        CategoryModel(id: 3, image: "IconJobDesign", name: "디자인"),
        CategoryModel(id: 4, image: "IconJobFinance", name: "재무/회계"),
        CategoryModel(id: 5, image: "IconJobSales", name: "영업"),
        CategoryModel(id: 6, image: "IconJobMed", name: "의료"),
        CategoryModel(id: 7, image: "IconJobEdu", name: "교육"),
        CategoryModel(id: 8, image: "IconJobLaw", name: "법"),
    ]
    
    @State var selectedCategory: Int64 = 1
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Group {
                    switch currentIndex {
                    case 0:
                        HomeView(profileViewModel: profileViewModel, currentMainIndex: $currentIndex, categories: categories, selectedCategory: $selectedCategory)
                    case 1:
                        FeedsView(
                            profileViewModel: profileViewModel, selectedCategory: $selectedCategory,
                            categories: categories)
                    case 2:
                        MypageView(profileViewModel: profileViewModel)
                    default: EmptyView()
                    }
                }
                .frame(maxHeight: .infinity)
                
                HStack(spacing: 88) {
                    // 홈
                    VStack(spacing: 2) {
                        VStack {
                            Image("IconBtmnavHome")
                                .resizable()
                                .foregroundColor(currentIndex == 0 ? .cheekMainStrong : .cheekTextAssitive)
                                .frame(width: 32, height: 32)
                        }
                        .frame(width: 32, height: 32)
                        
                        Text("홈")
                            .caption1(font: "SUIT", color: currentIndex == 0 ? .cheekMainStrong : .cheekTextAssitive, bold: true)
                    }
                    .onTapGesture {
                        currentIndex = 0
                    }
                    
                    // 피드
                    VStack(spacing: 2) {
                        VStack {
                            Image("IconBtmnavFeeds")
                                .resizable()
                                .foregroundColor(currentIndex == 1 ? .cheekMainStrong : .cheekTextAssitive)
                        }
                        .frame(width: 32, height: 32)
                        
                        Text("피드")
                            .caption1(font: "SUIT", color: currentIndex == 1 ? .cheekMainStrong : .cheekTextAssitive, bold: true)
                    }
                    .onTapGesture {
                        currentIndex = 1
                    }
                    
                    // MY
                    VStack(spacing: 2) {
                        VStack {
                            ProfileBtnnav(url: profileViewModel.profile?.profilePicture ?? "")
                                .opacity(currentIndex == 2 ? 1 :0.6)
                        }
                        .frame(width: 32, height: 32)
                        
                        Text("MY")
                            .caption1(font: "SUIT", color: currentIndex == 2 ? .cheekMainStrong : .cheekTextAssitive, bold: true)
                    }
                    .onTapGesture {
                        currentIndex = 2
                    }
                }
                .padding(.top, 10)
                .frame(maxWidth: .infinity)
                .frame(height: 63)
                .background(
                    Rectangle()
                        .foregroundColor(.cheekBackgroundTeritory)
                        .overlay(
                            Rectangle()
                                .frame(width: nil, height: 1, alignment: .top)
                                .foregroundColor(.cheekLineNormal)
                            , alignment: .top
                        )
                        .shadow(color: Color(red: 0.83, green: 0.82, blue: 0.82).opacity(0.2), radius: 5, x: 0, y: -2)
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.cheekBackgroundTeritory)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onAppear {
            UINavigationBar.setAnimationsEnabled(false)
        }
    }
}

#Preview {
    MainView(profileViewModel: ProfileViewModel())
}
