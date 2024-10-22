//
//  AddScrapFolderView.swift
//  CHEEK
//
//  Created by 김태은 on 10/22/24.
//

import SwiftUI

struct SelectScrappedFolderView: View {
    @Environment(\.dismiss) private var dismiss
    
    var storyModel: StoryModel
    
    @ObservedObject var profileViewModel: ProfileViewModel
    @Binding var isScrapOpen: Bool
    @Binding var isKeyboardUp: Bool
    
    @StateObject var viewModel: ScrapViewModel = ScrapViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text("폴더 선택")
                    .body1(font: "SUIT", color: .cheekTextNormal, bold: true)
                    .padding(.top, 36)
                
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(Array(viewModel.scrappedFolders.enumerated()), id: \.offset) { index, folder in
                            VStack(spacing: 16) {
                                Folder(folderModel: folder)
                                    .onTapGesture {
                                        addCollection(folderName: folder.folderName)
                                    }
                                
                                DividerSmall()
                            }
                        }
                        
                        NavigationLink(destination: AddScrapFolderView(storyModel: storyModel, profileViewModel: profileViewModel, scrapViewModel: viewModel, isScrapOpen: $isScrapOpen, isKeyboardUp: $isKeyboardUp)) {
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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.cheekBackgroundTeritory)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onAppear {
            isKeyboardUp = false
            getFolders()
        }
    }
    
    func getFolders() {
        guard let myId = profileViewModel.profile?.memberId else {
            print("profileViewModel에 profile이 없음")
            return
        }
        
        viewModel.getScrappedFolders(myId: myId)
    }
    
    func addCollection(folderName: String) {
        guard let myId = profileViewModel.profile?.memberId else {
            print("profileViewModel에 profile이 없음")
            return
        }
        
        viewModel.addCollection(myId: myId, storyId: storyModel.storyId, categoryId: storyModel.categoryId, forlderName: folderName) { isDone in
            isScrapOpen = false
        }
    }
}

#Preview {
    SelectScrappedFolderView(storyModel: StoryModel(storyId: 1, categoryId: 1, storyPicture: "", upvoted: false, upvoteCount: 0, memberDto: MemberDto(memberId: 1, nickname: "", profilePicture: "")), profileViewModel: ProfileViewModel(), isScrapOpen: .constant(true), isKeyboardUp: .constant(false))
}
