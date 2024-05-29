//
//  HomeView.swift
//  CHEEK
//
//  Created by 김태은 on 5/29/24.
//

import SwiftUI

struct HomeView: View {
    @State private var search: String = ""
    
    private var categoriesColumns: [GridItem] = Array(repeating: .init(.flexible()), count: 4)
    
    struct Category: Identifiable {
        let id = UUID()
        let name: String
    }
    
    let categories: [Category] = [
        Category(name: "개발"),
        Category(name: "기획"),
        Category(name: "디자인"),
        Category(name: "재무/회계"),
        Category(name: "영업"),
        Category(name: "의료"),
        Category(name: "교육"),
        Category(name: "법"),
    ]
    
    private var topUsersColumns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    
    struct TopUsers: Identifiable {
        let id = UUID()
        let name: String
        let job: String
        let introduction: String
        let profile: String
    }
    
    let topUsers: [TopUsers] = [
        TopUsers(name: "이름", job: "직무 한줄소개", introduction: "한줄소개", profile: ""),
        TopUsers(name: "이름", job: "직무 한줄소개", introduction: "한줄소개", profile: ""),
        TopUsers(name: "이름", job: "직무 한줄소개", introduction: "한줄소개", profile: ""),
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // 검색 및 알림
                    HStack(spacing: 16) {
                        HStack(spacing: 8) {
                            Image("IconReadingglass")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24)
                            
                            TextField(
                                "",
                                text: $search,
                                prompt:
                                    Text("프로필, 질문, 답변으로 검색하기")
                                    .foregroundColor(.cheekTextAlternative)
                            )
                            .caption1(font: "SUIT", color: .cheekTextStrong, bold: true)
                            .foregroundColor(.cheekTextStrong)
                        }
                        .padding(.horizontal, 19)
                        .frame(height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .foregroundColor(.cheekTextAssitive)
                        )
                        
                        Image("IconBell")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22)
                    }
                    .padding(.bottom, 20)
                    
                    // 배너
                    RoundedRectangle(cornerRadius: 16)
                        .frame(height: 160)
                        .foregroundColor(.cheekTextAssitive)
                        .padding(.bottom, 32)
                    
                    // 카테고리
                    LazyVGrid(columns: categoriesColumns, spacing: 20) {
                        ForEach(categories) { data in
                            VStack(spacing: 5) {
                                Circle()
                                    .frame(height: 72)
                                    .foregroundColor(.cheekTextAssitive)
                                
                                Text(data.name)
                                    .caption1(font: "SUIT", color: .cheekTextStrong, bold: true)
                            }
                            .frame(width: 72)
                        }
                    }
                    .padding(.bottom, 32)
                    
                    // 주간 TOP3 인기 유저
                    Text("주간 TOP3 인기 유저")
                        .label2(font: "SUIT", color: .cheekTextStrong, bold: true)
                        .padding(.bottom, 8)
                    
                    Text("주간 가장 많은 좋아요를 받은 유저예요")
                        .caption1(font: "SUIT", color: .cheekTextAlternative, bold: true)
                        .padding(.bottom, 16)
                    
                    LazyVGrid(columns: topUsersColumns) {
                        ForEach(topUsers) { data in
                            VStack(spacing: 0) {
                                Circle()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.cheekTextAssitive)
                                    .padding(.top, 13)
                                    .padding(.bottom, 8)
                                
                                Text(data.name)
                                    .font(.custom("SUIT", size: 8.5))
                                    .foregroundColor(.cheekTextStrong)
                                    .fontWeight(.semibold)
                                    .padding(.bottom, 2.5)
                                
                                Text(data.job)
                                    .font(.custom("SUIT", size: 6.5))
                                    .foregroundColor(.cheekTextStrong)
                                    .fontWeight(.semibold)
                                    .padding(.bottom, 6)
                                
                                ZStack {
                                    Rectangle()
                                        .foregroundColor(.cheekTextAssitive)
                                    
                                    Text(data.introduction)
                                        .font(.custom("SUIT", size: 6.5))
                                        .foregroundColor(.cheekTextStrong)
                                        .fontWeight(.semibold)
                                        .padding(.bottom, 6)
                                }
                            }
                            .frame(width: 111, height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundColor(.cheekBackgroundTeritory)
                                    .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 2)
                            )
                        }
                    }
                }
            }
        }
        .onAppear {
            UINavigationBar.setAnimationsEnabled(false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                UINavigationBar.setAnimationsEnabled(true)
            }
        }
        .padding(.top, 16)
        .padding(.horizontal, 25)
        .background(.cheekBackgroundTeritory)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
}

#Preview {
    HomeView()
}
