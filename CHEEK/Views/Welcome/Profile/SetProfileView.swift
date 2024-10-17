//
//  SetProfileMentee.swift
//  CHEEK
//
//  Created by 김태은 on 5/27/24.
//

import SwiftUI
import PhotosUI

struct SetProfileView: View {
    @Environment(\.dismiss) private var dismiss
    var isMentor: Bool
    
    @StateObject private var profileViewModel = ProfileViewModel()
    @StateObject private var viewModel = SetProfileViewModel()
    
    // 사진
    @State private var selectImage: UIImage?
    @State private var photosPickerItem: PhotosPickerItem?
    
    // 닉네임
    @State private var nickname: String = ""
    @FocusState private var isNicknameFocused: Bool
    @State var isUniqueNickname: Bool = false
    @State var statusNickname: TextFieldForm.statuses = .normal
    @State var infoNicknameForm: String = ""
    
    // 직무 한줄소개
    @State private var information: String = ""
    @State private var statusInformation: TextFieldForm.statuses = .normal
    @State private var infoInformationForm: String = ""
    @FocusState private var isInformationFocused: Bool
    
    // destination of navigation
    @State private var isDone: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    HStack {
                        Image("IconChevronLeft")
                            .foregroundColor(.cheekTextNormal)
                            .frame(width: 40, height: 40)
                            .onTapGesture {
                                dismiss()
                            }
                            .padding(8)
                        
                        Spacer()
                    }
                    .padding(.top, 8)
                    
                    Text("내 프로필을 설정해주세요.")
                        .headline1(font: "SUIT", color: .cheekTextNormal, bold: true)
                        .padding(.top, 28)
                    
                    // 프로필 사진 선택
                    PhotosPicker(selection: $photosPickerItem, matching: .images) {
                        if let image = selectImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 128, height: 128)
                                .clipShape(Circle())
                        } else {
                            Image("ImageDefaultProfile")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 128, height: 128)
                        }
                    }
                    .onChange(of: photosPickerItem) { image in
                        Task {
                            guard let data = try? await image?.loadTransferable(type: Data.self) else { return }
                            selectImage = UIImage(data: data)
                        }
                        
                        photosPickerItem = nil
                    }
                    .overlay(
                        Circle()
                            .stroke(.cheekWhite, lineWidth: 4)
                            .background(Circle().foregroundColor(.cheekMainNormal))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image("IconPlus")
                                    .resizable()
                                    .foregroundColor(.cheekWhite)
                                    .frame(width: 24, height: 24)
                            )
                        , alignment: .bottomTrailing
                    )
                    .padding(.top, 40)
                    
                    VStack(spacing: 24) {
                        // 닉네임
                        TextFieldForm(name: "닉네임", placeholder: "이름 또는 닉네임 입력", text: $nickname, information: $infoNicknameForm, status: $statusNickname, isFocused: $isNicknameFocused)
                            .onChange(of: nickname) { text in
                                if text.count > 8 {
                                    nickname = String(text.prefix(8))
                                }
                            }
                            .onChange(of: isNicknameFocused) { _ in
                                onChangeNicknameFocused()
                            }
                        
                        // 직무 한줄소개
                        TextFieldForm(name: "직무 한줄소개", placeholder: "예 > 당근 프론트엔드 개발자", text: $information, information: $infoInformationForm, status: $statusInformation, isFocused: $isInformationFocused)
                            .onChange(of: information) { text in
                                information = String(text.prefix(20))
                            }
                            .onChange(of: isInformationFocused) { _ in
                                if isInformationFocused {
                                    statusInformation = .focused
                                } else {
                                    statusInformation = .normal
                                }
                            }
                    }
                    .padding(.top, 48)
                    
                    Spacer()
                    
                    // 다음 버튼
                    if !viewModel.isLoading && !nickname.isEmpty && isUniqueNickname && !information.isEmpty {
                        ButtonActive(text: "다음")
                            .onTapGesture {
                                setProfile()
                            }
                    } else {
                        ButtonDisabled(text: "다음")
                    }
                }
                .padding(.bottom,
                         isNicknameFocused || isInformationFocused ? 24 : 31)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.cheekBackgroundTeritory)
                
                if viewModel.isLoading {
                    LoadingView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onTapGesture {
                Utils().hideKeyboard()
            }
        }
        .background(.cheekBackgroundTeritory)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $isDone, destination: {
            MainView(profileViewModel: profileViewModel)
        })
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("오류"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("확인")))
        }
    }
    
    // 닉네임 폼 중복 확인
    func onChangeNicknameFocused() {
        if !isNicknameFocused {
            statusNickname = .normal
            
            if nickname.isEmpty {
                statusNickname = .wrong
                infoNicknameForm = "닉네임을 입력해주세요."
            } else {
                viewModel.checkUniqueNickname(nickname: nickname) { response in
                    isUniqueNickname = response
                                                                
                    if response {
                        statusNickname = .correct
                        infoNicknameForm = "사용 가능한 닉네임입니다."
                    } else {
                        statusNickname = .wrong
                        infoNicknameForm = "중복된 닉네임입니다."
                    }
                }
            }
        }
    }
    
    // 프로필 설정
    func setProfile() {
        // 키보드 숨기기
        Utils().hideKeyboard()
        
        viewModel.isLoading = true
        
        viewModel.checkUniqueNickname(nickname: nickname) {
            response in
            if response {
                viewModel.setProfile(
                    profilePicture: selectImage,
                    nickname: nickname, information: information, isMentor: isMentor) { success in
                    if success {
                        profileViewModel.getMyProfile()
                        isDone = success
                    }
                }
            } else {
                viewModel.showError(message: "이미 등록된 닉네임입니다.")
            }
        }
    }
}

#Preview {
    SetProfileView(isMentor: false)
}
