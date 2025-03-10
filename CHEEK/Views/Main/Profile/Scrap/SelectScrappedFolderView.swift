//
//  AddScrapFolderView.swift
//  CHEEK
//
//  Created by 김태은 on 10/22/24.
//

import SwiftUI

struct SelectScrappedFolderView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var authViewModel: AuthenticationViewModel
    
    var storyModel: StoryModel
    
    @Binding var isScrapOpen: Bool
    @Binding var isKeyboardUp: Bool
    
    @Binding var triggerToast: Bool
    
    @StateObject var viewModel: ScrapViewModel = ScrapViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(spacing: 16) {
                        Capsule()
                            .frame(width: 32, height: 4)
                            .foregroundColor(.cheekLineNormal)
                        
                        // 상단
                        Text("폴더 선택")
                            .body1(font: "SUIT", color: .cheekTextNormal, bold: true)
                        
                        ScrollView {
                            VStack(spacing: 16) {
                                ForEach(Array(viewModel.scrappedFolders.enumerated()), id: \.offset) { index, folder in
                                    VStack(spacing: 16) {
                                        Button(action: {
                                            addCollection(folderName: folder.folderName)
                                        }) {
                                            Folder(folderModel: folder)
                                        }
                                        
                                        DividerSmall()
                                    }
                                }
                                
                                NavigationLink(destination: AddScrapFolderView(
                                    storyModel: storyModel,
                                    authViewModel: authViewModel,
                                    scrapViewModel: viewModel,
                                    isScrapOpen: $isScrapOpen,
                                    isKeyboardUp: $isKeyboardUp,
                                    triggerToast: $triggerToast
                                )) {
                                    HStack(spacing: 12) {
                                        Image("IconPlus")
                                            .resizable()
                                            .frame(width: 14, height: 14)
                                            .foregroundColor(.cheekTextNormal)
                                            .padding(13)
                                            .background(
                                                Circle()
                                                    .foregroundColor(.cheekLineNormal)
                                            )
                                        
                                        Text("새로운 폴더")
                                            .body2(font: "SUIT", color: .cheekTextNormal, bold: true)
                                        
                                        Spacer()
                                    }
                                }
                                
                                            
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                        }
                    }
                    .padding(.top, 16)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.cheekBackgroundTeritory)
                
                if viewModel.isLoading {
                    LoadingView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.cheekBackgroundTeritory)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onAppear {
            authViewModel.checkRefreshTokenValid()
            
            isKeyboardUp = false
            getFolders()
        }
    }
    
    func getFolders() {
        viewModel.getScrappedFolders()
    }
    
    func addCollection(folderName: String) {
        viewModel.addCollection(storyId: storyModel.storyId, categoryId: storyModel.categoryId, forlderName: folderName) { isDone in
            isScrapOpen = false
            triggerToast = true
        }
    }
}

#Preview {
    SelectScrappedFolderView(authViewModel: AuthenticationViewModel(), storyModel: StoryModel(storyId: 1, categoryId: 1, storyPicture: "", upvoted: false, upvoteCount: 0, memberDto: MemberDto(memberId: 1, nickname: "", profilePicture: "")), isScrapOpen: .constant(true), isKeyboardUp: .constant(false), triggerToast: .constant(false))
}
