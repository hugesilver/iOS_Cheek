//
//  MypageView.swift
//  CHEEK
//
//  Created by 김태은 on 6/12/24.
//

import SwiftUI

struct MypageView: View {
    @ObservedObject var profileViewModel: ProfileViewModel
    
    @State var isStoryOpen: Bool = false
    @State var selectedStories: [Int64] = []
    
    @State private var isInit: Bool = false
    
    @State private var menus: [String] = []
    
    @State private var selectedTab: Int = 0
    @State private var tabViewHeight: CGFloat = 1
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                HStack(spacing: 8) {
                    Text(profileViewModel.profile?.nickname ?? "불러오는 중...")
                        .headline1(font: "SUIT", color: .cheekTextStrong, bold: true)
                    
                    if profileViewModel.isMentor {
                        Image("IconMentor")
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                }
                
                Spacer()
                
                Image("IconPreference")
                    .foregroundColor(.cheekTextNormal)
                    .frame(width: 48, height: 48)
            }
            .padding(.top, 8)
            .padding(.horizontal, 16)
            
            ScrollViewReader { proxy in
                ScrollView {
                    EmptyView()
                        .id(0)
                    
                    VStack(spacing: 0) {
                        HStack {
                            ProfileXL(url: profileViewModel.profile?.profilePicture ?? "")
                            
                            Spacer()
                            
                            HStack(spacing: 0) {
                                VStack(spacing: 2) {
                                    Text("\(profileViewModel.stories.count)")
                                        .label1(font: "SUIT", color: .cheekTextStrong, bold: true)
                                    
                                    Text("스토리")
                                        .label2(font: "SUIT", color: .cheekTextAlternative, bold: false)
                                }
                                .frame(maxWidth: .infinity)
                                
                                Divider()
                                    .foregroundColor(Color(red: 0.85, green: 0.85, blue: 0.85))
                                    .frame(width: 1)
                                    .padding(.horizontal, 8)
                                
                                NavigationLink(destination:
                                                FollowView(myProfileViewModel: profileViewModel, targetMemberId: profileViewModel.profile?.memberId ?? 0, selectedTab: 0)) {
                                    VStack(spacing: 2) {
                                        Text(Utils().formatKoreanNumber(number: profileViewModel.profile?.followerCnt ?? 0))
                                            .label1(font: "SUIT", color: .cheekTextStrong, bold: true)
                                        
                                        Text("팔로워")
                                            .label2(font: "SUIT", color: .cheekTextAlternative, bold: false)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                
                                Divider()
                                    .foregroundColor(Color(red: 0.85, green: 0.85, blue: 0.85))
                                    .frame(width: 1)
                                    .padding(.horizontal, 8)
                                
                                NavigationLink(destination:
                                                FollowView(myProfileViewModel: profileViewModel, targetMemberId: profileViewModel.profile?.memberId ?? 0, selectedTab: 1)) {
                                    VStack(spacing: 2) {
                                        Text(Utils().formatKoreanNumber(number: profileViewModel.profile?.followingCnt ?? 0))
                                            .label1(font: "SUIT", color: .cheekTextStrong, bold: true)
                                        
                                        Text("팔로잉")
                                            .label2(font: "SUIT", color: .cheekTextAlternative, bold: false)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
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
                        
                        if profileViewModel.isMentor {
                            ScrollView(.horizontal) {
                                HStack(spacing: 16) {
                                    ForEach(profileViewModel.highlights) { highlight in
                                        VStack(spacing: 12) {
                                            ProfileL(url: highlight.thhumbnailPicture)
                                            
                                            Text(highlight.subject)
                                                .label2(font: "SUIT", color: .cheekTextNormal, bold: false)
                                        }
                                    }
                                    
                                    NavigationLink(destination: SelectHighlightView(profileViewModel: profileViewModel)) {
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
                                            
                                            Text("새로 만들기")
                                                .label2(font: "SUIT", color: .cheekTextNormal, bold: false)
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                            .padding(.top, 24)
                            
                            ProfileButtonNarrowLine(text: "스크랩된 스토리")
                                .padding(.top, 24)
                                .padding(.horizontal, 16)
                                .onTapGesture {
                                    
                                }
                        }
                        
                        TabsIcon(tabs: menus, selectedTab: $selectedTab)
                            .padding(.top, 24)
                            .padding(.horizontal, 16)
                        
                        TabView(selection: $selectedTab) {
                            if profileViewModel.isMentor {
                                ProfileStoriesView(isStoryOpen: $isStoryOpen, selectedStories: $selectedStories, stories: profileViewModel.stories)
                                    .background(
                                        GeometryReader { geometry in
                                            Color.clear
                                                .preference(key: HeightPreferenceKey.self, value: geometry.size.height)
                                        }
                                    )
                                    .onPreferenceChange(HeightPreferenceKey.self) { value in
                                        tabViewHeight = value
                                    }
                                    .tag(0)
                            }
                            
                            ProfileQuestionsView(questions: profileViewModel.questions)
                                .background(
                                    GeometryReader { geometry in
                                        Color.clear
                                            .preference(key: HeightPreferenceKey.self, value: geometry.size.height)
                                    }
                                )
                                .onPreferenceChange(HeightPreferenceKey.self) { value in
                                    tabViewHeight = value
                                }
                                .tag(profileViewModel.isMentor ? 1 : 0)
                        }
                        .frame(height: tabViewHeight)
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    }
                    .padding(.top, 24)
                }
                .onChange(of: profileViewModel.questions) { _ in
                    proxy.scrollTo(0, anchor: .top)
                }
                .onChange(of: profileViewModel.stories) { _ in
                    proxy.scrollTo(0, anchor: .top)
                }
                .onAppear {
                    proxy.scrollTo(0, anchor: .top)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.cheekBackgroundTeritory)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onAppear {
            initMenu()
            
            getDatas()
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
    
    
    // 메뉴 초기화
    func initMenu() {
        if !isInit {
            isInit = true
            
            if profileViewModel.isMentor {
                menus.append("IconStory")
            }
            
            menus.append("IconTalk")
        }
    }
    
    // 회원 데이터 조회
    func getDatas() {
        guard let myId = profileViewModel.profile?.memberId else {
            print("profileViewModel에 profile이 없음")
            return
        }
        
        profileViewModel.getMyProfile()
        
        // 하이라이트, 스토리
        if profileViewModel.isMentor {
            profileViewModel.getHighlights()
            profileViewModel.getStories(myId: myId)
        }
        
        // 질문
        profileViewModel.getQuestions()
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
    MypageView(profileViewModel: ProfileViewModel())
}
