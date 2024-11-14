//
//  StoryView.swift
//  CHEEK
//
//  Created by 김태은 on 10/12/24.
//

import SwiftUI
import Kingfisher

struct StoryView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var authViewModel: AuthenticationViewModel
    @Binding var storyIds: [Int64]
    
    @StateObject private var viewModel: StoryViewModel = StoryViewModel()
    
    @State private var offset: CGSize = .zero
    
    @State private var isScrapOpen: Bool = false
    @State private var isScrapKeyboardUp: Bool = false
    
    var body: some View {
        GeometryReader { reader in
            VStack(spacing: 0) {
                // 상단
                Color.cheekTextNormal
                    .frame(height: reader.safeAreaInsets.top, alignment: .top)
                
                ZStack(alignment: .top) {
                    if viewModel.isAllLoaded {
                        if !viewModel.stories.isEmpty {
                            KFImage(URL(string: viewModel.stories[viewModel.currentIndex].storyPicture))
                                .placeholder {
                                    Color.clear
                                }
                                .retry(maxCount: 2, interval: .seconds(2))
                                .onSuccess { result in
                                    
                                }
                                .onFailure { error in
                                    print("이미지 불러오기 실패: \(error)")
                                }
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(
                                    width: UIScreen.main.bounds.width,
                                    height: (UIScreen.main.bounds.width / 9) * 16
                                )
                                .background(.cheekMainNormal)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            
                            HStack(spacing: 4) {
                                ForEach(viewModel.stories.indices, id: \.self) { index in
                                    ProgressView(value: index == viewModel.currentIndex ? min(max(viewModel.timerProgress, 0.0), 1.0) : (index < viewModel.currentIndex ? 1.0 : 0.0))
                                        .progressViewStyle(LinearProgressViewStyle(tint: .cheekBackgroundTeritory))
                                        .background(.cheekBackgroundTeritory.opacity(0.4))
                                        .foregroundColor(.cheekBackgroundTeritory)
                                        .frame(height: 2)
                                        .clipShape(Capsule())
                                        .animation(viewModel.timerProgress > 0 ? .linear : nil, value: viewModel.timerProgress)
                                }
                            }
                            .frame(height: 2)
                            .padding(16)
                            .onChange(of: viewModel.isTimeOver) { isTimeOver in
                                if isTimeOver {
                                    goNext()
                                }
                            }
                            
                            HStack {
                                Color.clear
                                    .frame(maxWidth: UIScreen.main.bounds.width * 0.25, maxHeight: .infinity)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        goPrev()
                                    }
                                
                                Spacer()
                                
                                Color.clear
                                    .frame(maxWidth: UIScreen.main.bounds.width * 0.25, maxHeight: .infinity)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        goNext()
                                    }
                            }
                            
                            HStack(spacing: 8) {
                                ProfileXS(url: viewModel.stories[viewModel.currentIndex].memberDto.profilePicture)
                                
                                Text(viewModel.stories[viewModel.currentIndex].memberDto.nickname ?? "알 수 없는 사용자")
                                    .body2(font: "SUIT", color: .cheekWhite, bold: true)
                                
                                Spacer()
                            }
                            .padding(.top, 27)
                            .padding(.horizontal, 16)
                        } else {
                            Text("스토리를 불러올 수 없습니다.")
                                .body1(font: "SUIT", color: .cheekWhite, bold: false)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    } else {
                        LoadingView()
                    }
                    
                    HStack {
                        Spacer()
                        
                        // 닫기
                        Button(action: {
                            dismiss()
                        }) {
                            Image("IconX")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .foregroundColor(.cheekWhite)
                        }
                    }
                    .padding(.top, 27)
                    .padding(.horizontal, 16)
                }
                
                if !viewModel.stories.isEmpty && viewModel.isAllLoaded {
                    HStack(spacing: 8) {
                        Button(action: {
                            onTapLike()
                        }) {
                            HStack(spacing: 4) {
                                Image("IconHeart")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(viewModel.stories[viewModel.currentIndex].upvoted ? .cheekWhite : .cheekLineNormal)
                                
                                Text("좋아요")
                                    .body1(font: "SUIT", color: viewModel.stories[viewModel.currentIndex].upvoted ? .cheekWhite : .cheekLineNormal, bold: true)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundColor(viewModel.stories[viewModel.currentIndex].upvoted ? .cheekStatusAlert : .cheekGrey200)
                            )
                        }
                        
                        Button(action: {
                            isScrapOpen = true
                        }) {
                            HStack(spacing: 4) {
                                Image("IconCollection")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.cheekLineNormal)
                                
                                Text("스크랩")
                                    .body1(font: "SUIT", color: .cheekTextAssitive, bold: true)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundColor(.cheekGrey200)
                            )
                        }
                        .onChange(of: isScrapOpen) { _ in
                            if isScrapOpen {
                                viewModel.stopTimer()
                            } else {
                                viewModel.timerStory()
                            }
                        }
                    }
                    .padding(.top, 16)
                    .padding(.horizontal, 16)
                }
            }
            .background(.cheekTextNormal)
            .ignoresSafeArea(edges: .top)
            .offset(y: offset.height)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        if gesture.translation.height > 0 {
                            offset = gesture.translation
                        }
                    }
                    .onEnded { gesture in
                        if gesture.translation.height > UIScreen.main.bounds.height / 2 {
                            dismiss()
                        } else {
                            offset = .zero
                        }
                    }
            )
            .animation(.spring(), value: offset)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onAppear {
            viewModel.getStories(storyIds: storyIds)
        }
        .onDisappear {
            viewModel.stopTimer()
        }
        .sheet(isPresented: $isScrapOpen) {
            SelectScrappedFolderView(
                authViewModel: authViewModel,
                storyModel: viewModel.stories[viewModel.currentIndex],
                isScrapOpen: $isScrapOpen,
                isKeyboardUp: $isScrapKeyboardUp)
                .presentationDragIndicator(.hidden)
                .presentationDetents([.fraction((isScrapKeyboardUp ? 0.17 : 0.63))])
                .onDisappear {
                    isScrapKeyboardUp = false
                }
        }
    }
    
    // 이전으로
    func goPrev() {
        viewModel.timerProgress = 0
        
        if viewModel.currentIndex == 0 {
            viewModel.currentIndex = 0
        } else {
            viewModel.currentIndex -= 1
        }
    }
    
    // 다음으로
    func goNext() {
        if viewModel.currentIndex == viewModel.stories.count - 1 {
            viewModel.stopTimer()
            dismiss()
        } else {
            viewModel.timerProgress = 0
            viewModel.currentIndex += 1
        }
    }
    
    // 좋아요
    func onTapLike() {
        viewModel.stories[viewModel.currentIndex].upvoted.toggle()
        viewModel.likeStory()
    }
}

#Preview {
    StoryView(authViewModel: AuthenticationViewModel(), storyIds: .constant([1, 2]))
}
