//
//  SetHighlightView.swift
//  CHEEK
//
//  Created by 김태은 on 10/17/24.
//

import SwiftUI
import Kingfisher

struct SetHighlightView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var stateViewModel: StateViewModel
    @ObservedObject var profileViewModel: ProfileViewModel
    @ObservedObject var highlightViewModel: HighlightViewModel
    
    // 썸네일 이름
    @State private var statusSubject: TextFieldForm.statuses = .normal
    @State private var infoSubjectForm: String = ""
    @FocusState private var isSubjectFocused: Bool
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
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
                    
                    HStack(spacing: 4) {
                        Text(highlightViewModel.highlightId != nil ? "수정" : "등록")
                            .label1(font: "SUIT", color: .cheekTextNormal, bold: false)
                    }
                    .padding(.horizontal, 11)
                    .onTapGesture {
                        onTapDone()
                    }
                }
                .overlay(
                    Text("스토리 선택")
                        .label1(font: "SUIT", color: .cheekTextNormal, bold: true)
                    , alignment: .center
                )
                .padding(.top, 8)
                .padding(.horizontal, 16)
                
                VStack(spacing: 24) {
                    if highlightViewModel.originalThumbnail != nil {
                        Group {
                            if highlightViewModel.selectedStories.last?.storyPicture != nil {
                                KFImage(URL(string: highlightViewModel.selectedStories.last!.storyPicture))
                                    .placeholder {
                                        Image("ImageDefaultProfile")
                                            .resizable()
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
                                    .frame(width: 128, height: 128)
                                    .clipShape(Circle())
                            } else {
                                Image("ImageDefaultProfile")
                                    .resizable()
                                    .frame(width: 128, height: 128)
                                    .clipShape(Circle())
                            }
                        }
                    } else {
                        if highlightViewModel.thumbnail != nil {
                            Image(uiImage: highlightViewModel.thumbnail!)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 128, height: 128)
                                .clipShape(Circle())
                        } else {
                            Group {
                                if highlightViewModel.selectedStories.first?.storyPicture != nil {
                                    KFImage(URL(string: highlightViewModel.selectedStories.first!.storyPicture))
                                        .placeholder {
                                            Image("ImageDefaultProfile")
                                                .resizable()
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
                                        .frame(width: 128, height: 128)
                                        .clipShape(Circle())
                                } else {
                                    Image("ImageDefaultProfile")
                                        .resizable()
                                        .frame(width: 128, height: 128)
                                        .clipShape(Circle())
                                }
                            }
                            .frame(width: 128, height: 128)
                            .clipShape(Circle())
                        }
                    }
                    
                    NavigationLink(destination: ThumbnailEditingView(highlightViewModel: highlightViewModel)) {
                        Text("썸네일 수정")
                            .label1(font: "SUIT", color: .cheekStatusCaution, bold: true)
                            .multilineTextAlignment(.center)
                    }
                    
                }
                .padding(.top, 40)
                
                // 닉네임
                VStack {
                    TextFieldForm(
                        name: "이름",
                        placeholder: "도움말 텍스트",
                        isReqired: true,
                        text: $highlightViewModel.subject,
                        information: $infoSubjectForm,
                        status: $statusSubject,
                        isFocused: $isSubjectFocused)
                        .onChange(of: highlightViewModel.subject) { text in
                            if highlightViewModel.subject.count > 8 {
                                highlightViewModel.subject = String(text.prefix(12))
                            }
                        }
                        .onChange(of: isSubjectFocused) { _ in
                            onChangeSubjectFocused()
                        }
                }
                .padding(.top, 48)
                .padding(.horizontal, 16)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.cheekBackgroundTeritory)
            
            if highlightViewModel.isLoading {
                LoadingView()
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.cheekBackgroundTeritory)
        .onAppear {
            stateViewModel.checkRefreshTokenValid()
        }
        .alert(isPresented: $highlightViewModel.showAlert) {
            Alert(
                title: Text("오류"),
                message: Text(highlightViewModel.alertMessage)
            )
        }
    }
    
    // 이름 onChange
    func onChangeSubjectFocused() {
        if !isSubjectFocused {
            statusSubject = .normal
            
            if highlightViewModel.subject.isEmpty {
                statusSubject = .wrong
                infoSubjectForm = "이름을 입력해주세요."
            }
        }
    }
    
    // 하이라이트 등록 및 수정
    func onTapDone() {
        if !highlightViewModel.subject.isEmpty {
            // highlightViewModel.highlightId가 nil이 아니면 수정
            if highlightViewModel.highlightId != nil {
                highlightViewModel.editHighlight() { isDone in
                    DispatchQueue.main.async {
                        if isDone {
                            dismiss()
                            
                            profileViewModel.highlights = profileViewModel.highlights.filter {
                                $0.highlightId != highlightViewModel.highlightId
                            }
                        }
                    }
                }
            } else {
                highlightViewModel.addHighlight() { isDone in
                    DispatchQueue.main.async {
                        if isDone {
                            dismiss()
                        }
                    }
                }
            }
        } else {
            highlightViewModel.alertMessage = "제목은 필수입니다!"
            highlightViewModel.showAlert = true
        }
    }
}

#Preview {
    SetHighlightView(stateViewModel: StateViewModel(), profileViewModel: ProfileViewModel(), highlightViewModel: HighlightViewModel())
}
