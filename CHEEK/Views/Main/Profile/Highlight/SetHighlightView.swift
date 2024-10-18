//
//  SetHighlightView.swift
//  CHEEK
//
//  Created by 김태은 on 10/17/24.
//

import SwiftUI

struct SetHighlightView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var profileViewModel: ProfileViewModel
    @ObservedObject var highlightViewModel: HighlightViewModel
    
    var selectedStories: [StoryDto]
    
    // 썸네일 이름
    @State private var subject: String = ""
    @State private var statusSubject: TextFieldForm.statuses = .normal
    @State private var infoSubjectForm: String = ""
    @FocusState private var isSubjectFocused: Bool
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack {
                    Image("IconChevronLeft")
                        .foregroundColor(.cheekTextNormal)
                        .frame(width: 32, height: 32)
                        .onTapGesture {
                            dismiss()
                        }
                        .padding(8)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Text("등록")
                            .label1(font: "SUIT", color: .cheekTextNormal, bold: false)
                    }
                    .padding(.horizontal, 11)
                    .onTapGesture {
                        addHighlight()
                    }
                }
                .overlay(
                    Text("스토리 선택")
                        .title1(font: "SUIT", color: .cheekTextNormal, bold: true)
                    , alignment: .center
                )
                .padding(.top, 8)
                .padding(.horizontal, 16)
                
                VStack(spacing: 24) {
                    if highlightViewModel.thumbnail != nil {
                        Image(uiImage: highlightViewModel.thumbnail!)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 128, height: 128)
                            .clipShape(Circle())
                    } else {
                        Image("ImageDefaultProfile")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 128, height: 128)
                            .clipShape(Circle())
                    }
                    
                    NavigationLink(destination: ThumbnailEditingView(highlightViewModel: highlightViewModel, selectedStories: selectedStories)) {
                        Text("썸네일 수정")
                            .label1(font: "SUIT", color: .cheekStatusCaution, bold: true)
                            .multilineTextAlignment(.center)
                    }
                    
                }
                .padding(.top, 40)
                
                // 닉네임
                VStack {
                    TextFieldForm(name: "이름", placeholder: "도움말 텍스트", text: $subject, information: $infoSubjectForm, status: $statusSubject, isFocused: $isSubjectFocused)
                        .onChange(of: subject) { text in
                            if subject.count > 8 {
                                subject = String(text.prefix(12))
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
            
            if subject.isEmpty {
                statusSubject = .wrong
                infoSubjectForm = "이름을 입력해주세요."
            }
        }
    }
    
    // 하이라이트 등록
    func addHighlight() {
        if highlightViewModel.thumbnail != nil && !subject.isEmpty {
            guard let myId = profileViewModel.profile?.memberId else {
                print("profileViewModel에 profile이 없음")
                return
            }
            
            highlightViewModel.addHighlight(stories: selectedStories, subject: subject, memberId: myId) { isDone in
                DispatchQueue.main.async {
                    if isDone {
                        dismiss()
                    }
                }
            }
        } else {
            highlightViewModel.alertMessage = "썸네일과 제목은 모두 필수입니다!"
            highlightViewModel.showAlert = true
        }
    }
}

#Preview {
    SetHighlightView(profileViewModel: ProfileViewModel(), highlightViewModel: HighlightViewModel(), selectedStories: [])
}
