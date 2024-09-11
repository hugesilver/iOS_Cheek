//
//  ProfileView.swift
//  CHEEK
//
//  Created by 김태은 on 8/27/24.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var profileViewModel: ProfileViewModel
    
    @State private var selectedTab: Int = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    Image("IconChevronLeft")
                        .foregroundColor(.cheekTextNormal)
                        .frame(width: 32, height: 32)
                        .onTapGesture {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .padding(8)
                    
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
                        
                        HStack(spacing: 8) {
                            Text(profileViewModel.profile?.nickname ?? "불러오는 중...")
                                .headline1(font: "SUIT", color: .cheekTextStrong, bold: true)
                            
                            Circle()
                                .foregroundColor(.cheekMainHeavy)
                                .frame(width: 20, height: 20)
                            
                            Spacer()
                        }
                        .padding(.top, 16)
                        .padding(.horizontal, 16)
                        
                        Text(profileViewModel.profile?.information ?? "불러오는 중...")
                            .label2(font: "SUIT", color: .cheekTextAlternative, bold: false)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 4)
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
                                    
                                    Text("새로 만들기")
                                        .label2(font: "SUIT", color: .cheekTextNormal, bold: false)
                                }
                                .onTapGesture {
                                    
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        .padding(.top, 24)
                        
                        TabsIcon(tabs: ["IconStory", "IconTalk"], selectedTab: $selectedTab)
                            .padding(.top, 32)
                            .padding(.horizontal, 16)
                        
                        switch selectedTab {
                        case 0: ProfileStoriesView()
                        case 1: ProfileQuestionsView()
                        default: EmptyView()
                        }
                    }
                    .padding(.top, 24)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.cheekBackgroundTeritory)
        }
    }
}

#Preview {
    ProfileView(profileViewModel: ProfileViewModel())
}
