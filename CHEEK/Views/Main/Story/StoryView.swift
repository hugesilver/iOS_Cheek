//
//  StoryView.swift
//  CHEEK
//
//  Created by 김태은 on 10/12/24.
//

import SwiftUI

struct StoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var storyIds: [Int64]
    
    @ObservedObject var profileViewModel: ProfileViewModel
    @StateObject private var viewModel: StoryViewModel = StoryViewModel()
    
    @State private var offset: CGSize = .zero
    @State private var isDismissed: Bool = false
    
    var body: some View {
        NavigationStack {
            GeometryReader { reader in
                VStack(spacing: 0) {
                    // 상단
                    Color.cheekTextNormal
                        .frame(height: reader.safeAreaInsets.top, alignment: .top)
                    
                    ZStack(alignment: .top) {
                        if !viewModel.stories.isEmpty && viewModel.isAllLoaded {
                            AsyncImage(url: URL(string: viewModel.stories[viewModel.currentIndex].storyPicture)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(.cheekMainNormal)
                                    .clipped()
                            } placeholder: {
                                Color.clear
                            }
                            .frame(
                                width: UIScreen.main.bounds.width,
                                height: (UIScreen.main.bounds.width / 9) * 16
                            )
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
                            
                            HStack(spacing: 8) {
                                ProfileXS(url: viewModel.stories[viewModel.currentIndex].memberDto.profilePicture ?? "")
                                
                                Text(viewModel.stories[viewModel.currentIndex].memberDto.nickname)
                                    .body2(font: "SUIT", color: .cheekWhite, bold: true)
                                
                                Spacer()
                            }
                            .padding(.top, 27)
                            .padding(.horizontal, 18)
                            
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
                        } else {
                            LoadingView()
                        }
                    }
                    
                    
                    if !viewModel.stories.isEmpty && viewModel.isAllLoaded {
                        HStack(spacing: 8) {
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
                            .onTapGesture {
                                onTapLike()
                            }
                            
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
                            .onTapGesture {
                                
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
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onAppear {
            guard let myId = profileViewModel.profile?.memberId else {
                print("profileViewModel에 profile이 없음")
                return
            }
            
            viewModel.getStories(memberId: myId, storyIds: storyIds)
            UINavigationBar.setAnimationsEnabled(true)
        }
        .onDisappear {
            viewModel.cancelTimer()
            UINavigationBar.setAnimationsEnabled(false)
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
            viewModel.cancelTimer()
            dismiss()
        } else {
            viewModel.timerProgress = 0
            viewModel.currentIndex += 1
        }
    }
    
    // 좋아요
    func onTapLike() {
        guard let myId = profileViewModel.profile?.memberId else {
            print("profileViewModel에 profile이 없음")
            return
        }
        
        viewModel.stories[viewModel.currentIndex].upvoted.toggle()
        viewModel.likeStory(memberId: myId)
    }
}

#Preview {
    StoryView(storyIds: .constant([1, 2]), profileViewModel: ProfileViewModel())
}
