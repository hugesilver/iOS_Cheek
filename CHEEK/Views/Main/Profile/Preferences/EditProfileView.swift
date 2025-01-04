//
//  EditProfileView.swift
//  CHEEK
//
//  Created by 김태은 on 11/3/24.
//

import SwiftUI
import PhotosUI
import Kingfisher

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var authViewModel: AuthenticationViewModel
    @ObservedObject var profileViewModel: ProfileViewModel
    
    @StateObject private var viewModel = SetProfileViewModel()
    
    // 사진
    @State private var showPhotosPicker: Bool = false
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
    
    // 자기소개
    @State private var description: String = ""
    @State private var statusDescription: TextEditorForm.statuses = .normal
    @State private var infoDescriptionForm: String = ""
    @FocusState private var isDescriptionFocused: Bool
    
    var body: some View {
        ZStack {
            VStack {
                // 상단바
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image("IconChevronLeft")
                            .resizable()
                            .foregroundColor(.cheekTextNormal)
                            .frame(width: 32, height: 32)
                            .padding(8)
                    }
                    
                                            
                    
                    Spacer()
                    
                    Button(action: {
                        onTapDone()
                    }) {
                        Text("완료")
                            .label1(font: "SUIT", color: .cheekTextNormal, bold: false)
                            .padding(.horizontal, 18)
                    }
                }
                .overlay(
                    Text("계정 편집")
                        .label1(font: "SUIT", color: .cheekTextNormal, bold: true)
                    , alignment: .center
                )
                .padding(.top, 8)
                .padding(.horizontal, 16)
                
                ScrollView {
                    VStack {
                        // 프로필 사진 선택
                        Button(action: {
                            showPhotosPicker = true
                        }) {
                            if let image = selectImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 128, height: 128)
                                    .clipShape(Circle())
                            } else {
                                if profileViewModel.profile?.profilePicture != nil {
                                    KFImage(URL(string: profileViewModel.profile!.profilePicture!))
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
                                        .scaledToFill()
                                        .frame(width: 128, height: 128)
                                        .clipShape(Circle())
                                }
                            }
                        }
                        .photosPicker(isPresented: $showPhotosPicker, selection: $photosPickerItem, matching: .images)
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
                            TextFieldForm(
                                name: "닉네임",
                                placeholder: "이름 또는 닉네임 입력",
                                isReqired: true,
                                text: $nickname,
                                information: $infoNicknameForm,
                                status: $statusNickname,
                                isFocused: $isNicknameFocused)
                            .onChange(of: nickname) { text in
                                if text.count > 8 {
                                    nickname = String(text.replacing(" ", with: "").prefix(8))
                                } else {
                                    nickname = text.replacing(" ", with: "")
                                }
                            }
                            .onChange(of: isNicknameFocused) { _ in
                                onChangeNicknameFocused()
                            }
                            
                            // 직무 한줄소개
                            TextFieldForm(
                                name: "직무 한줄소개",
                                placeholder: "예 > 당근 프론트엔드 개발자",
                                isReqired: true,
                                text: $information,
                                information: $infoInformationForm,
                                status: $statusInformation,
                                isFocused: $isInformationFocused)
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
                            
                            // 자기소개
                            TextEditorForm(
                                height: 156,
                                name: "자기소개",
                                placeholder: "나를 소개할 문장을 입력합니다.",
                                isReqired: false,
                                text: $description,
                                information: $infoDescriptionForm,
                                status: $statusDescription,
                                isFocused: $isDescriptionFocused)
                            .onChange(of: description) { text in
                                if text.last == "\n" {
                                    description = String(text.dropLast())
                                    hideKeyboard()
                                }
                                
                                description = String(text.prefix(50))
                            }
                            .onChange(of: isDescriptionFocused) { _ in
                                if isDescriptionFocused {
                                    statusDescription = .focused
                                } else {
                                    statusDescription = .normal
                                }
                            }
                        }
                        .padding(.top, 48)
                        
                        Spacer()
                    }
                    .padding(.bottom,
                             isNicknameFocused || isInformationFocused ? 24 : 31)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.cheekBackgroundTeritory)
                    
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.cheekBackgroundTeritory)
            
            if viewModel.isLoading {
                LoadingView()
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("오류"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("확인")))
        }
        .onTapGesture {
            hideKeyboard()
        }
        .onAppear {
            authViewModel.checkRefreshTokenValid()
            
            if profileViewModel.profile != nil {
                nickname = profileViewModel.profile!.nickname
                information = profileViewModel.profile!.information
                description = profileViewModel.profile?.description ?? ""
            }
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("오류"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("확인")))
        }
    }
    
    @MainActor
    private func loadImage() -> some View {
        KFImage(URL(string: profileViewModel.profile!.profilePicture!))
            .placeholder {
                Image("ImageDefaultProfile")
                    .resizable()
            }
            .retry(maxCount: 2, interval: .seconds(2))
            .onSuccess { result in }
            .onFailure { error in
                print("이미지 불러오기 실패: \(error)")
            }
            .resizable()
            .cancelOnDisappear(true)
            .aspectRatio(contentMode: .fill)
            .frame(width: 128, height: 128)
            .clipShape(Circle())
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
    
    // 프로필 수정
    func onTapDone() {
        // 키보드 숨기기
        hideKeyboard()
        
        viewModel.isLoading = true
        
        if profileViewModel.profile != nil && profileViewModel.profile!.nickname == nickname {
            editProfile()
        } else {
            viewModel.checkUniqueNickname(nickname: nickname) {
                response in
                if response {
                    editProfile()
                } else {
                    viewModel.showError(message: "이미 등록된 닉네임입니다.")
                }
            }
        }
    }
    
    func editProfile() {
        viewModel.editProfile(
            profilePicture: selectImage,
            nickname: nickname,
            information: information,
            description: description) { success in
                if success {
                    DispatchQueue.main.async {
                        if let myMemberId = Keychain().read(key: "MEMBER_ID") {
                            profileViewModel.getProfile(targetMemberId: Int64(myMemberId)!)
                        }
                        
                        dismiss()
                    }
                } else {
                    viewModel.showError(message: "프로필 설정 중 오류가 발생했습니다.")
                }
            }
    }
}

#Preview {
    EditProfileView(authViewModel: AuthenticationViewModel(), profileViewModel: ProfileViewModel())
}
