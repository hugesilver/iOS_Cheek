//
//  HomeView.swift
//  CHEEK
//
//  Created by 김태은 on 5/29/24.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var stateViewModel: StateViewModel
    @ObservedObject var profileViewModel: ProfileViewModel
    @ObservedObject var notificationViewModel: NotificationViewModel
    
    @StateObject var viewModel: TopMembersViewModel = TopMembersViewModel()
    
    @Binding var currentMainIndex: Int
    
    @Binding var selectedCategory: Int64
    
    @State var banners: [String] = ["ImageBannerSample1"]
    
    @State var currentIndex: Int = 0
    @State var imgIndex: Int = 0
    
    var body: some View {
        GeometryReader { reader in
            VStack(spacing: 0) {
                // 상단
                Color.cheekMainNormal
                    .frame(height: reader.safeAreaInsets.top, alignment: .top)
                
                HStack(spacing: 0) {
                    NavigationLink(destination: SearchView(stateViewModel: stateViewModel, profileViewModel: profileViewModel)) {
                        HStack(spacing: 0) {
                            Text("회사, 사람 키워드로 검색")
                                .label1(font: "SUIT", color: .cheekTextAssitive, bold: false)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                            Spacer()
                        }
                        .background(
                            Capsule()
                                .fill(.cheekLineAlternative)
                        )
                    }
                    
                    NavigationLink(destination: NotificationView(stateViewModel: stateViewModel, notificationViewModel: notificationViewModel)) {
                        Image("IconBell")
                            .resizable()
                            .foregroundColor(.cheekTextNormal)
                            .frame(width: 48, height: 48)
                    }
                }
                .padding(.top, 24)
                .padding(.bottom, 16)
                .padding(.horizontal, 16)
                .background(.cheekMainNormal)
                
                ScrollView {
                    VStack(spacing: 0) {
                        TabView(selection: $currentIndex) {
                            ForEach(banners.indices, id: \.self) { index in
                                // AsyncImage(url: URL(string:""))
                                Image(banners[index])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .cornerRadius(16)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .frame(maxWidth: .infinity)
                        .frame(height: (UIScreen.main.bounds.width - (16 * 2)) * 0.4432133)
                        .onChange(of: currentIndex) { newIndex in
                            /*
                             if newIndex == 0  {
                             DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                             currentIndex = banners.count - 1
                             }
                             }
                             
                             if newIndex == banners.count - 1 {
                             DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                             currentIndex = 0
                             }
                             }
                             */
                        }
                        .overlay(
                            BannerList(currentIndex: currentIndex + 1, maxLength: banners.count)
                                .padding(.trailing, 21)
                                .padding(.bottom, 16), alignment: .bottomTrailing
                        )
                        .padding(.horizontal, 16)
                        .padding(.top, 24)
                        
                        LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 21), count: 4), spacing: 24) {
                            ForEach(CategoryModels().categories) { data in
                                VStack(spacing: 8) {
                                    Image(data.image)
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .padding(16)
                                        .background(Circle().fill(.cheekLineAlternative))
                                    
                                    Text(data.name)
                                        .label2(font: "SUIT", color: .cheekTextNormal, bold: true)
                                }
                                .onTapGesture {
                                    currentMainIndex = 1
                                    selectedCategory = data.id
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 32)
                    }
                    
                    DividerLarge()
                        .padding(.top, 32)
                    
                    HStack {
                        Category(title: "주간 TOP3 인기 유저", description: "주간 가장 많은 좋아요를 받은 유저예요")
                        
                        Spacer()
                    }
                    .padding(.top, 32)
                    .padding(.horizontal, 16)
                    
                    ScrollView(.horizontal) {
                        HStack(spacing: 16) {
                            ForEach(Array(viewModel.topMembers.enumerated()), id: \.offset) { index, data in
                                RankingCard(
                                    stateViewModel: stateViewModel,
                                    rank: index + 1,
                                    data: data)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 18)
                }
            }
            .ignoresSafeArea(edges: .top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.cheekBackgroundTeritory)
        .onAppear {
            stateViewModel.checkRefreshTokenValid()
            viewModel.getTopMembers()
        }
        .background(.cheekBackgroundTeritory)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
}

#Preview {
    HomeView(stateViewModel: StateViewModel(), profileViewModel: ProfileViewModel(), notificationViewModel: NotificationViewModel(), currentMainIndex: .constant(0), selectedCategory: .constant(1))
}
