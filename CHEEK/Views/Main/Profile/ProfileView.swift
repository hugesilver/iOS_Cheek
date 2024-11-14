//
//  ProfileView.swift
//  CHEEK
//
//  Created by 김태은 on 8/27/24.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    
    let targetMemberId: Int64
    @ObservedObject var authViewModel: AuthenticationViewModel
    
    @State private var myMemberId: Int64?
    
    @StateObject var profileViewModel: ProfileViewModel = ProfileViewModel()
    @StateObject var followViewModel: FollowViewModel = FollowViewModel()
    @StateObject private var highlightViewModel: HighlightViewModel = HighlightViewModel()
    
    @State var isStoryOpen: Bool = false
    @State var selectedStories: [Int64] = []
    
    @State private var isInit: Bool = false
    
    @State private var menus: [String] = []
    
    @State private var selectedTab: Int = 0
    @State private var tabViewHeights: [CGFloat] = [1, 1]
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    dismiss()}
                ) {
                    Image("IconChevronLeft")
                        .resizable()
                        .foregroundColor(.cheekTextNormal)
                        .frame(width: 32, height: 32)
                        .padding(8)
                }
                
                                            
                
                Spacer()
            }
            .padding(.top, 8)
            .padding(.horizontal, 16)
            
            ScrollViewReader { proxy in
                ScrollView {
                    EmptyView()
                        .id(0)
                    
                    VStack(spacing: 0) {
                        HStack(spacing: 16) {
                            ProfileXL(url: profileViewModel.profile?.profilePicture)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: profileViewModel.isMentor ? 3 : 2), spacing: 0) {
                                if profileViewModel.isMentor {
                                    VStack(spacing: 2) {
                                        Text("\(profileViewModel.stories.count)")
                                            .label1(font: "SUIT", color: .cheekTextStrong, bold: true)
                                        
                                        Text("스토리")
                                            .label2(font: "SUIT", color: .cheekTextAlternative, bold: false)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .overlay(
                                        Rectangle()
                                            .foregroundColor(Color(red: 0.85, green: 0.85, blue: 0.85))
                                            .frame(width: 1)
                                        , alignment: .trailing
                                    )
                                }
                                
                                NavigationLink(destination: FollowView(
                                    authViewModel: authViewModel,
                                    targetMemberId: profileViewModel.profile?.memberId ?? 0,
                                    selectedTab: 0)) {
                                        VStack(spacing: 2) {
                                            Text(Utils().formatKoreanNumber(number: profileViewModel.profile?.followerCnt ?? 0))
                                                .label1(font: "SUIT", color: .cheekTextStrong, bold: true)
                                            
                                            Text("팔로워")
                                                .label2(font: "SUIT", color: .cheekTextAlternative, bold: false)
                                        }
                                        .frame(maxWidth: .infinity)
                                    }
                                
                                NavigationLink(destination: FollowView(
                                    authViewModel: authViewModel,
                                    targetMemberId: profileViewModel.profile?.memberId ?? 0,
                                    selectedTab: 1)) {
                                        VStack(spacing: 2) {
                                            Text(Utils().formatKoreanNumber(number: profileViewModel.profile?.followingCnt ?? 0))
                                                .label1(font: "SUIT", color: .cheekTextStrong, bold: true)
                                            
                                            Text("팔로잉")
                                                .label2(font: "SUIT", color: .cheekTextAlternative, bold: false)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .overlay(
                                            Rectangle()
                                                .foregroundColor(Color(red: 0.85, green: 0.85, blue: 0.85))
                                                .frame(width: 1)
                                            , alignment: .leading
                                        )
                                    }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal, 16)
                        
                        HStack(spacing: 8) {
                            Text(profileViewModel.profile?.nickname ?? "불러오는 중...")
                                .headline1(font: "SUIT", color: .cheekTextStrong, bold: true)
                            
                            if profileViewModel.isMentor {
                                Image("IconMentor")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                            }
                            
                            Spacer()
                        }
                        .padding(.top, 16)
                        .padding(.horizontal, 16)
                        
                        Text(profileViewModel.profile?.information ?? "불러오는 중...")
                            .label2(font: "SUIT", color: .cheekTextAlternative, bold: false)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 4)
                            .padding(.horizontal, 16)
                        
                        if profileViewModel.profile?.description != nil && !profileViewModel.profile!.description!.isEmpty {
                            Text(profileViewModel.profile!.description!)
                                .body2(font: "SUIT", color: .cheekTextNormal, bold: false)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 8)
                                .padding(.horizontal, 16)
                        }
                        
                        if myMemberId != nil && profileViewModel.profile != nil && myMemberId != targetMemberId {
                            if profileViewModel.profile!.following {
                                Button(action: {
                                    onTapUnfollow()
                                }) {
                                    ButtonUnfollow(text: "언팔로우")
                                        .padding(.top, 24)
                                        .padding(.horizontal, 16)
                                }
                            } else {
                                Button(action: {
                                    onTapFollow()
                                }) {
                                    ButtonFollow(text: "팔로우")
                                        .padding(.top, 24)
                                        .padding(.horizontal, 16)
                                }
                            }
                        }
                        
                        if profileViewModel.isMentor && !profileViewModel.highlights.isEmpty {
                            ScrollView(.horizontal) {
                                HStack(spacing: 16) {
                                    ForEach(profileViewModel.highlights) { highlight in
                                        Button(action: {
                                            onTapHighlight(highlight: highlight)
                                        }) {
                                            VStack(spacing: 12) {
                                                ProfileL(url: highlight.thumbnailPicture)
                                                
                                                Text(highlight.subject)
                                                    .label2(font: "SUIT", color: .cheekTextNormal, bold: false)
                                            }
                                            .frame(maxWidth: 72)
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                            .padding(.top, 24)
                        }
                        
                        TabsIcon(tabs: menus, selectedTab: $selectedTab)
                            .padding(.top, 24)
                            .padding(.horizontal, 16)
                        
                        TabView(selection: $selectedTab) {
                            if profileViewModel.isMentor {
                                ProfileStoriesView(
                                    isStoryOpen: $isStoryOpen,
                                    selectedStories: $selectedStories,
                                    stories: profileViewModel.stories)
                                .background(
                                    GeometryReader { geometry in
                                        Color.clear
                                            .preference(key: HeightPreferenceKey.self, value: geometry.size.height)
                                    }
                                )
                                .onPreferenceChange(HeightPreferenceKey.self) { value in
                                    tabViewHeights[0] = value
                                }
                                .tag(0)
                            }
                            
                            ProfileQuestionsView(
                                authViewModel: authViewModel,
                                profileViewModel: profileViewModel,
                                questions: profileViewModel.questions)
                            .background(
                                GeometryReader { geometry in
                                    Color.clear
                                        .preference(key: HeightPreferenceKey.self, value: geometry.size.height)
                                }
                            )
                            .onPreferenceChange(HeightPreferenceKey.self) { value in
                                tabViewHeights[profileViewModel.isMentor ? 1 : 0] = value
                            }
                            .tag(profileViewModel.isMentor ? 1 : 0)
                        }
                        .frame(height: tabViewHeights[selectedTab])
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .onChange(of: selectedTab) { _ in
                            print(selectedTab)
                            print(tabViewHeights[selectedTab])
                            proxy.scrollTo(0, anchor: .top)
                        }
                    }
                    .padding(.top, 24)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.cheekBackgroundTeritory)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.cheekBackgroundTeritory)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onAppear {
            getProfileData()
        }
        .onChange(of: profileViewModel.profile) { _ in
            if profileViewModel.profile != nil {
                initMenu()
                
                // 하이라이트, 스토리
                if profileViewModel.isMentor {
                    profileViewModel.getHighlights(targetMemberId: targetMemberId)
                    profileViewModel.getStories(targetMemberId: targetMemberId)
                }
                
                // 질문
                profileViewModel.getQuestions(targetMemberId: targetMemberId)
            }
        }
        .fullScreenCover(isPresented: $isStoryOpen) {
            if #available(iOS 16.4, *) {
                StoryView(authViewModel: authViewModel, storyIds: $selectedStories)
                    .presentationBackground(.clear)
            } else {
                StoryView(authViewModel: authViewModel, storyIds: $selectedStories)
            }
        }
    }
    
    
    // 메뉴 초기화
    func initMenu() {
        if let myId = Keychain().read(key: "MEMBER_ID") {
            myMemberId = Int64(myId)!
        }
        
        if !isInit {
            isInit = true
            
            if profileViewModel.isMentor {
                menus.append("IconStory")
            }
            
            menus.append("IconTalk")
        }
    }
    
    // 회원 데이터 조회
    func getProfileData() {
        profileViewModel.getProfile(targetMemberId: targetMemberId)
    }
    
    // 팔로우
    func onTapFollow() {
        followViewModel.follow(toMemberId: targetMemberId)
        
        if profileViewModel.profile != nil {
            profileViewModel.profile!.following = true
            profileViewModel.profile!.followerCnt += 1
        }
    }
    
    // 언팔로우
    func onTapUnfollow() {
        followViewModel.unfollow(toMemberId: targetMemberId)
        
        if profileViewModel.profile != nil {
            profileViewModel.profile!.following = false
            profileViewModel.profile!.followerCnt -= 1
        }
    }
    
    func onTapHighlight(highlight: HighlightListModel) {
        highlightViewModel.getHighlight(highlightId: highlight.highlightId) { isDone in
            selectedStories = highlightViewModel.highlightStories!.storyId
            isStoryOpen = true
        }
    }
}

struct ButtonFollow: View {
    var text: String
    
    var body: some View {
        Text(text)
            .body1(font: "SUIT", color: .cheekTextNormal, bold: true)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.cheekMainNormal)
            )
    }
}

struct ButtonUnfollow: View {
    var text: String
    
    var body: some View {
        Text(text)
            .body1(font: "SUIT", color: .cheekTextAlternative, bold: true)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.cheekLineNormal)
            )
    }
}

#Preview {
    ProfileView(targetMemberId: 1, authViewModel: AuthenticationViewModel(), profileViewModel: ProfileViewModel())
}
