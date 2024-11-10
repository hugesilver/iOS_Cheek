//
//  DeleteStoryView.swift
//  CHEEK
//
//  Created by 김태은 on 10/28/24.
//

import SwiftUI
import Kingfisher

fileprivate let vGridSpacing: CGFloat = 4

struct DeleteStoryView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var authViewModel: AuthenticationViewModel
    @ObservedObject var profileViewModel: ProfileViewModel
    
    enum deleteModeTypes {
        case delete, none
    }
    
    @State var deleteMode: deleteModeTypes = .delete
    @State var showAlert: Bool = false
    
    var body: some View {
        VStack(spacing: 8) {
            // 상단바
            HStack {
                Image("IconChevronLeft")
                    .resizable()
                    .foregroundColor(.cheekTextNormal)
                    .frame(width: 32, height: 32)
                    .onTapGesture {
                        dismiss()
                    }
                    .padding(8)
                
                Spacer()
                
                if profileViewModel.selectedStoriesForDelete.count > 0 {
                    HStack(spacing: 4) {
                        Text("완료")
                            .label1(font: "SUIT", color: .cheekTextNormal, bold: false)
                        
                        Text("\(profileViewModel.selectedStoriesForDelete.count)")
                            .label1(font: "SUIT", color: .cheekMainStrong, bold: true)
                    }
                    .padding(.horizontal, 11)
                    .onTapGesture {
                        deleteMode = .delete
                        showAlert = true
                    }
                } else {
                    Text("완료")
                        .label1(font: "SUIT", color: .cheekTextNormal, bold: false)
                        .padding(.horizontal, 18)
                        .onTapGesture {
                            deleteMode = .none
                            showAlert = true
                        }
                }
            }
            .overlay(
                Text("내 스토리 삭제")
                    .label1(font: "SUIT", color: .cheekTextNormal, bold: true)
                , alignment: .center
            )
            .padding(.top, 8)
            .padding(.horizontal, 16)
        }
        
        // 스토리 모음
        ScrollView {
            LazyVGrid(columns:  Array(repeating: .init(.flexible(), spacing: vGridSpacing), count: 3), spacing: 4) {
                ForEach(profileViewModel.stories) { story in
                    ZStack(alignment: .leading) {
                        KFImage(URL(string: story.storyPicture))
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
                            .frame(
                                width: (UIScreen.main.bounds.width / 3) - (vGridSpacing / 2),
                                height: 156
                            )
                            .clipped()
                        
                        if profileViewModel.selectedStoriesForDelete.contains(story) {
                            Rectangle()
                                .foregroundColor(.cheekMainNormal.opacity(0.2))
                                .overlay(
                                    Rectangle()
                                        .strokeBorder(.cheekMainNormal, lineWidth: 2)
                                )
                        }
                        
                        VStack {
                            if profileViewModel.selectedStoriesForDelete.contains(story) {
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
                            
                            Text(Utils().convertToKST(dateString: story.modifiedAt!)!)
                                .caption1(font: "SUIT", color: .cheekWhite, bold: true)
                                .frame(alignment: .bottomLeading)
                                .padding(8)
                        }
                    }
                    .contentShape(Rectangle())
                    .frame(height: 156)
                    .onTapGesture {
                        if let index = profileViewModel.selectedStoriesForDelete.firstIndex(of: story) {
                            profileViewModel.selectedStoriesForDelete.remove(at: index)
                        } else {
                            profileViewModel.selectedStoriesForDelete.append(story)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.cheekBackgroundTeritory)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onAppear {
            authViewModel.checkRefreshTokenValid()
        }
        .alert(isPresented: $showAlert) {
            switch deleteMode {
            case .delete:
                Alert(
                    title: Text("경고"),
                    message: Text("정말 \(profileViewModel.selectedStoriesForDelete.count)개의 스토리들을 지울까요?"),
                    primaryButton: .destructive(Text("삭제")) {
                        deleteStories()
                    },
                    secondaryButton: .cancel(Text("취소"))
                )
            case .none:
                Alert(
                    title: Text("알림"),
                    message: Text("스토리를 선택해주세요.")
                )
            }
        }
    }
    
    // 스토리 삭제
    func deleteStories() {
        profileViewModel.deleteStories()
    }
}

#Preview {
    DeleteStoryView(authViewModel: AuthenticationViewModel(), profileViewModel: ProfileViewModel())
}
