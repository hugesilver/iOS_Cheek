//
//  SearchView.swift
//  CHEEK
//
//  Created by 김태은 on 8/26/24.
//

import SwiftUI
import WrappingHStack

struct SearchView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText: String = ""
    
    var test = ["test","test3", "test2323", "test2323", "test233", "test2323"]
    
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
                            presentationMode.wrappedValue.dismiss()
                        }
                        .padding(8)
                    
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 9) {
                                ChipSearch(text: "test", onTap: ChipOnClose)
                                    .id(0)
                                
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
                /*
                 ScrollView {
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
                 }
                 .padding(.top, 16)
                 .padding(.horizontal, 16)
                 
                 ScrollView(.horizontal, showsIndicators: false) {
                 HStack(spacing: 8) {
                 ChipDefault(text: "test")
                 }
                 .padding(.horizontal, 16)
                 }
                 .padding(.top, 8)
                 
                 // 트렌딩 키워드
                 HStack {
                 Category(title: "트렌딩 키워드", description: "지난 7일간 가장 많이 발견된 키워드에요!")
                 
                 Spacer()
                 }
                 .padding(.top, 40)
                 .padding(.leading, 16)
                 
                 WrappingHStack(test, id: \.self, spacing: .constant(8), lineSpacing: 8) { data in
                 ChipDefault(text: data)
                 }
                 .padding(.top, 8)
                 .padding(.horizontal, 16)
                 
                 
                 Spacer()
                 }
                 */
                
                // 검색 후
                Group {
                    TabsText(tabs: ["전체", "프로필", "Q&A"], selectedTab: $selectedTab)
                        .padding(.top, 16)
                    
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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.cheekBackgroundTeritory)
            .onTapGesture {
                hideKeyboard()
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
    
    // 키보드 숨기기
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func ChipOnClose() {
        print("working")
    }
}

#Preview {
    SearchView()
}
