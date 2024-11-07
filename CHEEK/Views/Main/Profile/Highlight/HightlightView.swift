//
//  StoryView.swift
//  CHEEK
//
//  Created by 김태은 on 10/12/24.
//

import SwiftUI

struct HighlightView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var authViewModel: AuthenticationViewModel
    @ObservedObject var profileViewModel: ProfileViewModel
    
    @Binding var highlightId: Int64
    @Binding var highlightThumbnail: String
    @Binding var highlightSubject: String
    
    @StateObject private var storyViewModel: StoryViewModel = StoryViewModel()
    @StateObject private var highlightViewModel: HighlightViewModel = HighlightViewModel()
    
    @State private var offset: CGSize = .zero
    
    @State private var showAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            GeometryReader { reader in
                VStack(spacing: 0) {
                    // 상단
                    Color.cheekTextNormal
                        .frame(height: reader.safeAreaInsets.top, alignment: .top)
                    
                    ZStack(alignment: .top) {
                        if storyViewModel.isAllLoaded {
                            if !storyViewModel.stories.isEmpty {
                                AsyncImage(url: URL(string: storyViewModel.stories[storyViewModel.currentIndex].storyPicture)) { image in
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
                                    ForEach(storyViewModel.stories.indices, id: \.self) { index in
                                        ProgressView(value: index == storyViewModel.currentIndex ? min(max(storyViewModel.timerProgress, 0.0), 1.0) : (index < storyViewModel.currentIndex ? 1.0 : 0.0))
                                            .progressViewStyle(LinearProgressViewStyle(tint: .cheekBackgroundTeritory))
                                            .background(.cheekBackgroundTeritory.opacity(0.4))
                                            .foregroundColor(.cheekBackgroundTeritory)
                                            .frame(height: 2)
                                            .clipShape(Capsule())
                                            .animation(storyViewModel.timerProgress > 0 ? .linear : nil, value: storyViewModel.timerProgress)
                                    }
                                }
                                .frame(height: 2)
                                .padding(16)
                                .onChange(of: storyViewModel.isTimeOver) { isTimeOver in
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
                                    ProfileXS(url: storyViewModel.stories[storyViewModel.currentIndex].memberDto.profilePicture)
                                    
                                    Text(storyViewModel.stories[storyViewModel.currentIndex].memberDto.nickname)
                                        .body2(font: "SUIT", color: .cheekWhite, bold: true)
                                    
                                    Spacer()
                                }
                                .padding(.top, 27)
                                .padding(.horizontal, 16)
                            } else {
                                Text("스토리를 불러올 수 없습니다.")
                                    .body1(font: "SUIT", color: .cheekWhite, bold: false)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: (UIScreen.main.bounds.width / 9) * 16)
                            }
                        } else {
                            LoadingView()
                        }
                        
                        HStack {
                            Spacer()
                            
                            // 닫기
                            Image("IconX")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .foregroundColor(.cheekWhite)
                                .onTapGesture {
                                    dismiss()
                                }
                        }
                        .padding(.top, 27)
                        .padding(.horizontal, 16)
                    }
                    
                    if storyViewModel.isAllLoaded {
                        HStack(spacing: 8) {
                            NavigationLink(destination: EditHighlightView(authViewModel: authViewModel, profileViewModel: profileViewModel, highlightViewModel: highlightViewModel)) {
                                Text("하이라이트 수정")
                                    .body1(font: "SUIT", color: .cheekTextAssitive, bold: true)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundColor(.cheekGrey200)
                            )
                            .onAppear {
                                storyViewModel.timerStory()
                            }
                            .simultaneousGesture(TapGesture().onEnded{
                                storyViewModel.stopTimer()
                            })
                            
                            Text("하이라이트 삭제")
                                .body1(font: "SUIT", color: .cheekWhite, bold: true)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .foregroundColor(.cheekStatusAlert)
                                )
                                .onTapGesture {
                                    storyViewModel.stopTimer()
                                    showAlert = true
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
            authViewModel.isRefreshTokenValid = authViewModel.checkRefreshTokenValid()
            
            onInit()
            
            storyViewModel.timerStory()
            
            if highlightViewModel.isDone {
                dismiss()
            }
        }
        .onDisappear {
            storyViewModel.stopTimer()
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("경고"),
                message: Text("정말 이 하이라이트를 지울까요?"),
                primaryButton: .destructive(Text("삭제")) {
                    deleteHighlight()
                },
                secondaryButton: .cancel(Text("취소")) {
                    storyViewModel.timerStory()
                }
            )
        }
    }
    
    func onInit() {
        highlightViewModel.getHighlight(highlightId: highlightId) { isDone in
            if isDone {
                storyViewModel.getStories(storyIds: highlightViewModel.highlightStories!.storyId)
                
                highlightViewModel.setSelectedStories(
                    storyIds: highlightViewModel.highlightStories!.storyId,
                    stories: profileViewModel.stories)
            }
        }
        
        highlightViewModel.highlightId = highlightId
        highlightViewModel.originalThumbnail = highlightThumbnail
        highlightViewModel.convertUIImage(url: highlightThumbnail)
        highlightViewModel.subject = highlightSubject
    }
    
    // 이전으로
    func goPrev() {
        storyViewModel.timerProgress = 0
        
        if storyViewModel.currentIndex == 0 {
            storyViewModel.currentIndex = 0
        } else {
            storyViewModel.currentIndex -= 1
        }
    }
    
    // 다음으로
    func goNext() {
        if storyViewModel.currentIndex == storyViewModel.stories.count - 1 {
            storyViewModel.stopTimer()
            dismiss()
        } else {
            storyViewModel.timerProgress = 0
            storyViewModel.currentIndex += 1
        }
    }
    
    // 하이라이트 삭제
    func deleteHighlight() {
        highlightViewModel.deleteHighlight() { isDone in
            if isDone {
                DispatchQueue.main.async {
                    profileViewModel.highlights.removeAll { $0.highlightId == highlightViewModel.highlightId }
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    HighlightView(authViewModel: AuthenticationViewModel(), profileViewModel: ProfileViewModel(), highlightId: .constant(0), highlightThumbnail: .constant(""), highlightSubject: .constant(""))
}
