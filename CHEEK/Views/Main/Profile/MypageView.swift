//
//  MypageView.swift
//  CHEEK
//
//  Created by 김태은 on 6/12/24.
//

import SwiftUI

struct MypageView: View {
    @ObservedObject var profileViewModel: ProfileViewModel
    
    @Binding var isPresented: Bool
    @Binding var path: MainView.PATHS
    
    @State private var selectedTab: Int = 0
    @State private var tabViewHeight: CGFloat = 1
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                HStack(spacing: 8) {
                    Text(profileViewModel.profile?.nickname ?? "불러오는 중...")
                        .headline1(font: "SUIT", color: .cheekTextStrong, bold: true)
                    
                    Circle()
                        .foregroundColor(.cheekMainHeavy)
                        .frame(width: 20, height: 20)
                }
                
                Spacer()
                
                Image("IconPreference")
                    .foregroundColor(.cheekTextNormal)
                    .frame(width: 48, height: 48)
            }
            .padding(.top, 8)
            .padding(.horizontal, 16)
            
            ScrollView {
                VStack(spacing: 0) {
                    HStack {
                        ProfileXL(url: "")
                        
                        Spacer()
                        
                        HStack(spacing: 0) {
                            VStack(spacing: 2) {
                                Text("200")
                                    .label1(font: "SUIT", color: .cheekTextStrong, bold: true)
                                
                                Text("스토리")
                                    .label2(font: "SUIT", color: .cheekTextAlternative, bold: false)
                            }
                            .frame(maxWidth: .infinity)
                            
                            Divider()
                                .foregroundColor(Color(red: 0.85, green: 0.85, blue: 0.85))
                                .frame(width: 1)
                                .padding(.horizontal, 8)
                            
                            VStack(spacing: 2) {
                                Text("4.2천")
                                    .label1(font: "SUIT", color: .cheekTextStrong, bold: true)
                                
                                Text("팔로워")
                                    .label2(font: "SUIT", color: .cheekTextAlternative, bold: false)
                            }
                            .frame(maxWidth: .infinity)
                            
                            Divider()
                                .foregroundColor(Color(red: 0.85, green: 0.85, blue: 0.85))
                                .frame(width: 1)
                                .padding(.horizontal, 8)
                            
                            VStack(spacing: 2) {
                                Text("320")
                                    .label1(font: "SUIT", color: .cheekTextStrong, bold: true)
                                
                                Text("팔로잉")
                                    .label2(font: "SUIT", color: .cheekTextAlternative, bold: false)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    Text(profileViewModel.profile?.information ?? "불러오는 중...")
                        .label2(font: "SUIT", color: .cheekTextAlternative, bold: false)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 16)
                        .padding(.horizontal, 16)
                    
                    if profileViewModel.profile?.description != nil && ((profileViewModel.profile?.description!.isEmpty) == nil) {
                        Text(profileViewModel.profile!.description!)
                            .body2(font: "SUIT", color: .cheekTextNormal, bold: false)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 8)
                            .padding(.horizontal, 16)
                    }
                    
                    ButtonNarrowFill(text: "팔로우")
                        .padding(.top, 24)
                        .padding(.horizontal, 16)
                    
                    ScrollView(.horizontal) {
                        HStack(spacing: 16) {
                            VStack(spacing: 12) {
                                ProfileL(url: "")
                                
                                Text("test")
                                    .label2(font: "SUIT", color: .cheekTextNormal, bold: false)
                            }
                            
                            VStack(spacing: 12) {
                                Image("IconPlus")
                                    .resizable()
                                    .foregroundColor(.cheekTextNormal)
                                    .frame(width: 24, height: 24)
                                    .padding(24)
                                    .background(
                                        Circle()
                                            .foregroundColor(.cheekMainStrong)
                                    )
                                    .onTapGesture {
                                        path = .highlight
                                        isPresented = true
                                    }
                                
                                Text("새로 만들기")
                                    .label2(font: "SUIT", color: .cheekTextNormal, bold: false)
                            }
                            .onTapGesture {
                                
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.top, 24)
                    
                    /*
                    ProfileButtonNarrowLine(text: "스크랩된 스토리")
                        .padding(.top, 24)
                        .padding(.horizontal, 16)
                        .onTapGesture {
                            
                        }
                     */
                    
                    TabsIcon(tabs: ["IconStory", "IconTalk"], selectedTab: $selectedTab)
                        .padding(.top, 24)
                        .padding(.horizontal, 16)
                    
                    TabView(selection: $selectedTab) {
                        ProfileStoriesView()
                            .background(
                                GeometryReader { geometry in
                                    Color.clear
                                        .preference(key: HeightPreferenceKey.self, value: geometry.size.height)
                                }
                            )
                            .onPreferenceChange(HeightPreferenceKey.self) { value in
                                if selectedTab == 0 {
                                    tabViewHeight = value
                                }
                            }
                            .tag(0)
                        
                        ProfileQuestionsView()
                            .background(
                                GeometryReader { geometry in
                                    Color.clear
                                        .preference(key: HeightPreferenceKey.self, value: geometry.size.height)
                                }
                            )
                            .onPreferenceChange(HeightPreferenceKey.self) { value in
                                if selectedTab == 1 {
                                    tabViewHeight = value
                                }
                            }
                            .tag(1)
                    }
                    .frame(height: tabViewHeight)
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
                .padding(.top, 24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.cheekBackgroundTeritory)
        }
    }
}

struct HeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

struct ProfileButtonNarrowLine: View {
    var text: String
    
    var body: some View {
        Text(text)
            .body1(font: "SUIT", color: .cheekTextNormal, bold: true)
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.cheekTextAssitive, lineWidth: 1)
                    .foregroundColor(.cheekWhite)
            )
    }
}

#Preview {
    MypageView(profileViewModel: ProfileViewModel(), isPresented: .constant(false), path: .constant(.highlight))
}