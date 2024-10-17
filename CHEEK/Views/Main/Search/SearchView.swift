//
//  SearchView.swift
//  CHEEK
//
//  Created by 김태은 on 8/26/24.
//

import SwiftUI
import WrappingHStack

struct SearchView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: SearchViewModel = SearchViewModel()
    
    @State private var searchText: String = ""
    @State private var selectedTab: Int = 0
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                // 뒤로가기와 검색
                HStack {
                    Image("IconChevronLeft")
                        .foregroundColor(.cheekTextNormal)
                        .frame(width: 32, height: 32)
                        .onTapGesture {
                            dismiss()
                        }
                        .padding(8)
                    
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 9) {
//                                if let keyword {
//                                    ChipSearch(text: keyword, onTap: ChipOnClose)
//                                        .id(0)
//                                }
                                
                                TextField(
                                    "",
                                    text: $searchText,
                                    prompt: Text("회사, 사람, 키워드로 검색")
                                        .foregroundColor(.cheekTextAlternative)
                                )
                                .label1(font: "SUIT", color: .cheekTextNormal, bold: true)
                                .foregroundColor(.cheekTextStrong)
                                .id(1)
                                .onChange(of: searchText) { _ in
                                    proxy.scrollTo(1, anchor: .trailing)
                                    
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                        }
                        .background(
                            Capsule()
                                .foregroundColor(.cheekLineAlternative)
                        )
                    }
                }
                .padding(.top, 8)
                .padding(.horizontal, 16)
                
                // 검색 전
                if !viewModel.isSearched {
                    ScrollView {
                        if !viewModel.recentSearches.isEmpty {
                            VStack(spacing: 8) {
                                // 최근 검색
                                HStack {
                                    Text("최근 검색")
                                        .label1(font: "SUIT", color: .cheekTextStrong, bold: true)
                                        .padding(.vertical, 12)
                                    
                                    Spacer()
                                    
                                    Text("전체 삭제")
                                        .label2(font: "SUIT", color: .cheekTextAlternative, bold: false)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 14)
                                        .onTapGesture {
                                            viewModel.removeAllSearched()
                                        }
                                }
                                .padding(.horizontal, 16)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(viewModel.recentSearches, id: \.self) { search in
                                            ChipDefault(text: search)
                                                .onTapGesture {
                                                    searchText = search
                                                }
                                        }
                                        
                                    }
                                    .padding(.horizontal, 16)
                                }
                            }
                            .padding(.top, 16)
                        }
                        
                        // 트렌딩 키워드
                        HStack {
                            Category(title: "트렌딩 키워드", description: "지난 7일간 가장 많이 발견된 키워드에요!")
                            
                            Spacer()
                        }
                        .padding(.top, 40)
                        .padding(.leading, 16)
                        
                        WrappingHStack(viewModel.trendingKeywords, id: \.self, spacing: .constant(8), lineSpacing: 8) { keyword in
                            ChipDefault(text: keyword)
                                .onTapGesture {
                                    self.searchText = keyword
                                }
                        }
                        .padding(.top, 8)
                        .padding(.horizontal, 16)
                        
                        
                        Spacer()
                    }
                }
                // 검색 후
                else {
                    VStack(spacing: 16) {
                        TabsText(tabs: ["전체", "프로필", "Q&A"], selectedTab: $selectedTab)
                        
                        TabView(selection: $selectedTab) {
                            SearchResultAllView()
                                .tag(0)
                            
                            SearchResultProfileView()
                                .tag(1)
                            
                            SearchResultQuestionView()
                                .tag(2)
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.cheekBackgroundTeritory)
            .onTapGesture {
                Utils().hideKeyboard()
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onAppear {
            viewModel.getRecentSearched()
            viewModel.getTrendingKeywords()
        }
    }
}

#Preview {
    SearchView()
}
