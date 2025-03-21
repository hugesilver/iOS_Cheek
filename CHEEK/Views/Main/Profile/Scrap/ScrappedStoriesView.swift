//
//  ScrappedStoriesView.swift
//  CHEEK
//
//  Created by 김태은 on 10/22/24.
//

import SwiftUI
import Kingfisher

fileprivate let LAZY_V_GRID_SPACING: CGFloat = 4

struct ScrappedStoriesView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var authViewModel: AuthenticationViewModel
    @ObservedObject var scrapViewModel: ScrapViewModel
    var folderModel: ScrapFolderModel
    
    @State private var isSelectable: Bool = false
    
    @State var isStoryOpen: Bool = false
    @State var selectedStories: [Int64] = []
    
    enum deleteModeTypes {
        case collections, folder, empty, none
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
                        Button(action: {
                            isSelectable = false
                        }) {
                            Text("완료")
                                .label1(font: "SUIT", color: .cheekTextNormal, bold: false)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 12)
                        }
                        
                        Spacer()
                        
                        if selectedCollections.count > 0 {
                            Button(action: {
                                if selectedCollections.count == scrapViewModel.collections.count {
                                    deleteMode = .folder
                                    showAlert = true
                                } else {
                                    deleteMode = .collections
                                    showAlert = true
                                }
                            }) {
                                HStack(spacing: 4) {
                                    Text("삭제")
                                        .label1(font: "SUIT", color: .cheekStatusAlert, bold: true)
                                    
                                    Text("\(selectedCollections.count)")
                                        .label1(font: "SUIT", color: .cheekMainStrong, bold: true)
                                }
                                .padding(.horizontal, 11)
                                .padding(.vertical, 12)
                            }
                        } else {
                            Button(action: {
                                if scrapViewModel.collections.isEmpty {
                                    deleteMode = .empty
                                } else {
                                    deleteMode = .none
                                }
                                
                                showAlert = true
                            }) {
                                Text("삭제")
                                    .label1(font: "SUIT", color: .cheekStatusAlert, bold: true)
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 12)
                            }
                        }
                    }
                    .overlay(
                        Text(folderModel.folderName)
                            .body1(font: "SUIT", color: .cheekTextNormal, bold: true)
                        , alignment: .center
                    )
                    .padding(.top, 8)
                    .padding(.horizontal, 16)
                    .background(.cheekBackgroundTeritory)
                    
                    // 컬렉션 모음
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: LAZY_V_GRID_SPACING), count: 3), spacing: 4) {
                            ForEach(scrapViewModel.collections) { collection in
                                ZStack(alignment: .leading) {
                                    KFImage(URL(string: collection.storyPicture))
                                        .placeholder {
                                            Color.cheekLineAlternative
                                        }
                                        .retry(maxCount: 2, interval: .seconds(2))
                                        .onSuccess { result in
                                            
                                        }
                                        .onFailure { error in
                                            print("이미지 불러오기 실패: \(error)")
                                        }
                                        .resizable()
                                        .cancelOnDisappear(true)
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 156)
                                        .frame(maxWidth: .infinity)
                                        .clipped()
                                    
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
                                        
                                        Text(convertToDate(dateString: collection.modifiedAt) ?? "")
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
                        
                        Button(action: {
                            isSelectable = true
                        }) {
                            Text("편집")
                                .label1(font: "SUIT", color: .cheekTextNormal, bold: false)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 12)
                        }
                    }
                    .overlay(
                        Text(folderModel.folderName)
                            .body1(font: "SUIT", color: .cheekTextNormal, bold: true)
                        , alignment: .center
                    )
                    .padding(.top, 8)
                    .padding(.horizontal, 16)
                    .background(.cheekBackgroundTeritory)
                    
                    // 컬렉션 모음
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: LAZY_V_GRID_SPACING), count: 3), spacing: 4) {
                            ForEach(scrapViewModel.collections) { collection in
                                ZStack(alignment: .leading) {
                                    KFImage(URL(string: collection.storyPicture))
                                        .placeholder {
                                            Color.cheekLineAlternative
                                        }
                                        .retry(maxCount: 2, interval: .seconds(2))
                                        .onSuccess { result in
                                            
                                        }
                                        .onFailure { error in
                                            print("이미지 불러오기 실패: \(error)")
                                        }
                                        .resizable()
                                        .cancelOnDisappear(true)
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 156)
                                        .frame(maxWidth: .infinity)
                                        .clipped()
                                    
                                    VStack {
                                        Spacer()
                                        
                                        Text(convertToDate(dateString: collection.modifiedAt) ?? "")
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.cheekBackgroundTeritory)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onAppear {
            authViewModel.checkRefreshTokenValid()
            
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
            case .empty:
                Alert(
                    title: Text("경고"),
                    message: Text("콜렉션이 모두 비어있습니다.\n폴더를 삭제할까요?"),
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
                
                selectedStories = []
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
