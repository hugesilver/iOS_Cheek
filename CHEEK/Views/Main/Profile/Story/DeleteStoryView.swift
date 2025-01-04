//
//  DeleteStoryView.swift
//  CHEEK
//
//  Created by 김태은 on 10/28/24.
//

import SwiftUI
import Kingfisher

fileprivate let LAZY_V_GRID_SPACING: CGFloat = 4

struct DeleteStoryView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var authViewModel: AuthenticationViewModel
    @ObservedObject var profileViewModel: ProfileViewModel
    
    enum deleteModeTypes {
        case delete, none, error
    }
    
    @State var deleteMode: deleteModeTypes = .delete
    @State var showAlert: Bool = false
    
    var body: some View {
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
                
                if profileViewModel.selectedStoriesForDelete.count > 0 {
                    Button(action: {
                        deleteMode = .delete
                        showAlert = true
                    }) {
                        HStack(spacing: 4) {
                            Text("완료")
                                .label1(font: "SUIT", color: .cheekTextNormal, bold: false)
                            
                            Text("\(profileViewModel.selectedStoriesForDelete.count)")
                                .label1(font: "SUIT", color: .cheekMainStrong, bold: true)
                        }
                        .padding(.horizontal, 11)
                    }
                } else {
                    Button(action: {
                        deleteMode = .none
                        showAlert = true
                    }) {
                        Text("완료")
                            .label1(font: "SUIT", color: .cheekTextNormal, bold: false)
                            .padding(.horizontal, 18)
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
            
            // 스토리 모음
            ScrollView {
                LazyVGrid(columns:  Array(repeating: GridItem(.flexible(), spacing: LAZY_V_GRID_SPACING), count: 3), spacing: 4) {
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

                                .frame(height: 156)
                                .frame(maxWidth: .infinity)
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
                                
                                Text(convertToDate(dateString: story.modifiedAt!) ?? "")
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
            case .error:
                Alert(
                    title: Text("오류"),
                    message: Text("스토리를 삭제하지 못 했습니다.")
                )
            }
        }
    }
    
    // 스토리 삭제
    func deleteStories() {
        profileViewModel.deleteStories() { isDone in
            if !isDone {
                deleteMode = .error
                showAlert = true
            }
        }
    }
}

#Preview {
    DeleteStoryView(authViewModel: AuthenticationViewModel(), profileViewModel: ProfileViewModel())
}
