//
//  ScrappedStoriesView.swift
//  CHEEK
//
//  Created by 김태은 on 10/22/24.
//

import SwiftUI

struct ScrappedStoriesView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var authViewModel: AuthenticationViewModel
    @ObservedObject var scrapViewModel: ScrapViewModel
    var folderModel: ScrapFolderModel
    
    var storyColumns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 4), count: 3)
    
    @State private var isSelectable: Bool = false
    
    @State var isStoryOpen: Bool = false
    @State var selectedStories: [Int64] = []
    
    enum deleteModeTypes {
        case collections, folder, none
    }
    
    @State var selectedCollections: [CollectionModel] = []
    @State var showAlert: Bool = false
    @State var deleteMode: deleteModeTypes = .collections
    
    var body: some View {
        Group {
            // 콜렉션 선택
            if isSelectable {
                VStack(spacing: 8) {
                    // 상단바
                    HStack {
                        Text("완료")
                            .label1(font: "SUIT", color: .cheekTextNormal, bold: false)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 12)
                            .onTapGesture {
                                isSelectable = false
                            }
                        
                        Spacer()
                        
                        if selectedCollections.count > 0 {
                            HStack(spacing: 4) {
                                Text("삭제")
                                    .label1(font: "SUIT", color: .cheekStatusAlert, bold: true)
                                
                                Text("\(selectedCollections.count)")
                                    .label1(font: "SUIT", color: .cheekMainStrong, bold: true)
                            }
                            .padding(.horizontal, 11)
                            .padding(.vertical, 12)
                            .onTapGesture {
                                if selectedCollections.count == scrapViewModel.collections.count {
                                    deleteMode = .folder
                                    showAlert = true
                                } else {
                                    deleteMode = .collections
                                    showAlert = true
                                }
                            }
                        } else {
                            Text("삭제")
                                .label1(font: "SUIT", color: .cheekStatusAlert, bold: true)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 12)
                                .onTapGesture {
                                    deleteMode = .none
                                    showAlert = true
                                }
                        }
                    }
                    .overlay(
                        Text(folderModel.folderName)
                            .title1(font: "SUIT", color: .cheekTextNormal, bold: true)
                        , alignment: .center
                    )
                    .padding(.top, 8)
                    .padding(.horizontal, 16)
                    
                    // 컬렉션 모음
                    ScrollView {
                        LazyVGrid(columns: storyColumns, spacing: 4) {
                            ForEach(scrapViewModel.collections) { collection in
                                ZStack(alignment: .leading) {
                                    AsyncImage(url: URL(string: collection.storyPicture)) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(
                                                width: (UIScreen.main.bounds.width / 3) - (vGridSpacing / 2),
                                                height: 156
                                            )
                                            .clipped()
                                    } placeholder: {
                                        Color.cheekLineAlternative
                                    }
                                    
                                    if selectedCollections.contains(collection) {
                                        Rectangle()
                                            .foregroundColor(.cheekMainNormal.opacity(0.2))
                                            .overlay(
                                                Rectangle()
                                                    .strokeBorder(.cheekMainNormal, lineWidth: 2)
                                            )
                                    }
                                    
                                    VStack {
                                        if selectedCollections.contains(collection) {
                                            Circle()
                                                .frame(width: 24, height: 24)
                                                .foregroundColor(.cheekMainNormal)
                                                .overlay(
                                                    Image("IconCheck")
                                                        .resizable()
                                                        .frame(width: 16, height: 16)
                                                        .foregroundColor(.cheekTextNormal)
                                                )
                                                .padding(8)
                                        } else {
                                            Circle()
                                                .foregroundColor(Color(red: 0.29, green: 0.29, blue: 0.29).opacity(0.6))
                                                .frame(width: 24, height: 24)
                                                .overlay(
                                                    Circle()
                                                        .strokeBorder(.cheekWhite, lineWidth: 2)
                                                )
                                                .padding(8)
                                        }
                                        
                                        Spacer()
                                    }
                                    
                                    VStack {
                                        Spacer()
                                        
                                        Text(Utils().convertToKST(dateString: collection.modifiedAt)!)
                                            .caption1(font: "SUIT", color: .cheekWhite, bold: true)
                                            .frame(alignment: .bottomLeading)
                                            .padding(8)
                                    }
                                }
                                .contentShape(Rectangle())
                                .frame(height: 156)
                                .onTapGesture {
                                    if let index = selectedCollections.firstIndex(of: collection) {
                                        selectedCollections.remove(at: index)
                                    } else {
                                        selectedCollections.append(collection)
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.cheekBackgroundTeritory)
                }
            }
            // 콜렉션 선택 아님
            else {
                VStack(spacing: 8) {
                    // 상단바
                    HStack {
                        Image("IconChevronLeft")
                            .foregroundColor(.cheekTextNormal)
                            .frame(width: 32, height: 32)
                            .onTapGesture {
                                dismiss()
                            }
                            .padding(8)
                        
                        Spacer()
                        
                        Text("편집")
                            .label1(font: "SUIT", color: .cheekTextNormal, bold: false)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 12)
                            .onTapGesture {
                                isSelectable = true
                            }
                    }
                    .overlay(
                        Text(folderModel.folderName)
                            .title1(font: "SUIT", color: .cheekTextNormal, bold: true)
                        , alignment: .center
                    )
                    .padding(.top, 8)
                    .padding(.horizontal, 16)
                    
                    ScrollView {
                        LazyVGrid(columns: storyColumns, spacing: 4) {
                            ForEach(scrapViewModel.collections) { collection in
                                ZStack(alignment: .leading) {
                                    AsyncImage(url: URL(string: collection.storyPicture)) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(
                                                width: (UIScreen.main.bounds.width / 3) - (vGridSpacing / 2),
                                                height: 156
                                            )
                                            .clipped()
                                    } placeholder: {
                                        Color.cheekLineAlternative
                                    }
                                    
                                    VStack {
                                        Spacer()
                                        
                                        Text(Utils().convertToKST(dateString: collection.modifiedAt)!)
                                            .caption1(font: "SUIT", color: .cheekWhite, bold: true)
                                            .frame(alignment: .bottomLeading)
                                            .padding(8)
                                    }
                                }
                                .contentShape(Rectangle())
                                .frame(height: 156)
                                .onTapGesture {
                                    selectedStories = [collection.storyId]
                                    isStoryOpen = true
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.cheekBackgroundTeritory)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onAppear {
            authViewModel.isRefreshTokenValid = authViewModel.checkRefreshTokenValid()
            
            scrapViewModel.getCollections(folderId: folderModel.folderId)
        }
        .onDisappear {
            scrapViewModel.collections = []
        }
        .fullScreenCover(isPresented: $isStoryOpen) {
            if #available(iOS 16.4, *) {
                StoryView(authViewModel: authViewModel, storyIds: $selectedStories)
                    .presentationBackground(.clear)
            } else {
                StoryView(authViewModel: authViewModel, storyIds: $selectedStories)
            }
        }
        .alert(isPresented: $showAlert) {
            switch deleteMode {
            case .collections:
                Alert(
                    title: Text("경고"),
                    message: Text("정말 이 콜렉션들을 지울까요?"),
                    primaryButton: .destructive(Text("삭제")) {
                        deleteCollections()
                    },
                    secondaryButton: .cancel(Text("취소"))
                )
            case .folder:
                Alert(
                    title: Text("경고"),
                    message: Text("모든 콜렉션을 선택하셨습니다.\n해당 폴더를 삭제할까요?"),
                    primaryButton: .destructive(Text("삭제")) {
                        deleteFolder()
                    },
                    secondaryButton: .cancel(Text("취소"))
                )
            case .none:
                Alert(
                    title: Text("알림"),
                    message: Text("콜렉션을 선택해주세요.")
                )
            }
        }
    }
    
    func deleteCollections() {
        // scrapViewModel.collections에 선택한 콜렉션 제거
        scrapViewModel.deleteCollections(collectionList: selectedCollections) { isDeleted in
            if isDeleted {
                scrapViewModel.collections = scrapViewModel.collections.filter {
                    !selectedCollections.contains($0)
                }
            }
        }
    }
    
    func deleteFolder() {
        scrapViewModel.deleteCollections(collectionList: selectedCollections) { isDeletedCollections in
            if isDeletedCollections {
                scrapViewModel.deleteFolder(folderId: folderModel.folderId) { isDeletedFolder in
                    if isDeletedFolder {
                        DispatchQueue.main.async {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ScrappedStoriesView(authViewModel: AuthenticationViewModel(), scrapViewModel: ScrapViewModel(), folderModel: ScrapFolderModel(folderId: 1, folderName: "", thumbnailPicture: ""))
}
