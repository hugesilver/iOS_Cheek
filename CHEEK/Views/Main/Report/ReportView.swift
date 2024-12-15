//
//  ReportView.swift
//  CHEEK
//
//  Created by 김태은 on 12/15/24.
//

import SwiftUI

struct ReportView: View {
    @Environment(\.dismiss) private var dismiss
    
    let category: String
    let categoryId: Int64
    let toMemberId: Int64
    
    @StateObject private var viewModel: ReportViewModel = .init()
    
    // 제목 폼
    @State private var title: String = ""
    @State var statusTitle: TextFieldForm.statuses = .normal
    @FocusState var isTitleFocused: Bool
    
    // 인증번호 폼
    @State private var content: String = ""
    @State var statusContent: TextEditorForm.statuses = .normal
    @FocusState var isContentFocused: Bool
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image("IconChevronLeft")
                            .resizable()
                            .foregroundColor(.cheekTextNormal)
                            .frame(width: 40, height: 40)
                            .padding(4)
                    }
                    
                    Spacer()
                }
                .padding(.top, 8)
                
                Text("해당 \(changeCategoryToText(category)) 신고하기")
                    .headline1(font: "SUIT", color: .cheekTextNormal, bold: true)
                    .padding(.top, 24)
                
                Text("제목과 신고 내용을 적어주세요.")
                    .label1(font: "SUIT", color: .cheekTextAlternative, bold: true)
                    .padding(.top, 4)
                
                VStack(spacing: 16) {
                    TextFieldForm(
                        name: "제목",
                        placeholder: "제목을 입력하세요.",
                        keyboardType: .default,
                        isReqired: true,
                        text: $title,
                        information: .constant(""),
                        status: $statusTitle,
                        isFocused: $isTitleFocused)
                    
                    TextEditorForm(
                        height: 156,
                        name: "신고 내용",
                        placeholder: "신고 내용을 입력하세요.",
                        isReqired: true,
                        text: $content,
                        information: .constant(""),
                        status: $statusContent,
                        isFocused: $isContentFocused)
                }
                .padding(.top, 16)
                
                Spacer()
                
                // 제출
                if !title.isEmpty && !content.isEmpty {
                    Button(action: {
                        viewModel.sendReport(category: category, categoryId: categoryId, toMemberId: toMemberId, title: title, content: content)
                    }) {
                        ButtonActive(text: "제출")
                    }
                   
                } else {
                    ButtonDisabled(text: "제출")
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom,
                     isTitleFocused || isContentFocused ? 24 : 31)
            
            if viewModel.isLoading {
                LoadingView()
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.cheekBackgroundTeritory)
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text(viewModel.alertMessage), dismissButton: .default(Text("확인")) {
                DispatchQueue.main.async {
                    dismiss()
                }
            })
        }
    }
    
    func changeCategoryToText(_ category: String) -> String {
        switch category {
        case "MEMBER": return "회원"
        case "STORY": return "스토리"
        case "QUESTION": return "질문"
        default: return ""
        }
    }
}

#Preview {
    ReportView(category: "MEMBER", categoryId: 0, toMemberId: 0)
}
