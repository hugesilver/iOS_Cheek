//
//  SetProfileMentee.swift
//  CHEEK
//
//  Created by 김태은 on 5/27/24.
//

import SwiftUI
import PhotosUI

struct SetProfileMenteeView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var socialProvider: String
    
    @StateObject private var setProfileMenteeViewModel = SetProfileMenteeViewModel()
    
    @State private var selectImage: UIImage?
    @State private var photosPickerItem: PhotosPickerItem?
    
    @State private var nickname: String = ""
    @State private var information: String = ""
    
    @State private var isLoading: Bool = false
    @State private var isDone: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    HStack {
                        Image("IconArrowLeft")
                            .frame(width: 24, height: 24)
                            .onTapGesture {
                                presentationMode.wrappedValue.dismiss()
                            }
                        
                        Spacer()
                    }
                    .padding(.bottom, 24)
                    
                    Text("내 프로필을 설정해주세요.")
                        .title1(font: "SUIT", color: .cheekTextStrong, bold: true)
                        .padding(.bottom, 48)
                    
                    // 프로필 사진 선택
                    PhotosPicker(selection: $photosPickerItem, matching: .images) {
                        if let image = selectImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 114, height: 114)
                                .cornerRadius(20)
                        } else {
                            Circle()
                                .frame(width: 114, height: 114)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(.cheekTextAssitive)
                                        .overlay(
                                            Image("IconPlus")
                                                .frame(width: 38, height: 38)
                                        )
                                )
                        }
                    }
                    .padding(.bottom, 40)
                    .onChange(of: photosPickerItem) { image in
                        Task {
                            guard let data = try? await image?.loadTransferable(type: Data.self) else { return }
                            selectImage = UIImage(data: data)
                        }
                        
                        photosPickerItem = nil
                    }
                    
                    // 닉네임
                    VStack(spacing: 6) {
                        HStack {
                            Text("닉네임")
                                .caption1(font: "SUIT", color: .cheekTextStrong, bold: true)
                            Spacer()
                        }
                        
                        // 닉네임 작성란
                        TextField(
                            "",
                            text: $nickname,
                            prompt:
                                Text("이름 또는 닉네임 입력")
                                .foregroundColor(.cheekTextAssitive)
                        )
                        .caption1(font: "SUIT", color: .cheekTextStrong, bold: true)
                        .foregroundColor(.cheekTextStrong)
                        .padding(.leading, 11)
                        .frame(height: 36)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.cheekTextAssitive, lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 17)
                    .padding(.bottom, 16)
                    
                    // 한줄소개
                    VStack(spacing: 6) {
                        HStack {
                            Text("한줄소개")
                                .caption1(font: "SUIT", color: .cheekTextStrong, bold: true)
                            Spacer()
                        }
                        
                        // 닉네임 작성란
                        TextField(
                            "",
                            text: $information,
                            prompt:
                                Text("예 > iOS 개발 취업준비생")
                                .foregroundColor(.cheekTextAssitive)
                        )
                        .caption1(font: "SUIT", color: .cheekTextStrong, bold: true)
                        .foregroundColor(.cheekTextStrong)
                        .padding(.leading, 11)
                        .frame(height: 36)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.cheekTextAssitive, lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 17)
                    .padding(.bottom, 16)
                    
                    Spacer()
                    
                    // 확인 버튼
                    Text("확인")
                        .label1(font: "SUIT", color: .cheekTextNormal, bold: true)
                        .frame(maxWidth: .infinity)
                        .frame(height: 41)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(!nickname.isEmpty ? .cheekMainHeavy : Color(red: 0.85, green: 0.85, blue: 0.85))
                        )
                        .padding(.horizontal, 17)
                        .onTapGesture {
                            hideKeyboard()
                            if !nickname.isEmpty {
                                isLoading = true
                                setProfileMenteeViewModel.setProfile(socialProvider: socialProvider, nickname: nickname, information: information, profilePicture: selectImage) { success in
                                    isDone = success
                                    isLoading = false
                                }
                            }
                        }
                }
                .padding(.top, 48)
                .padding(.bottom, 40)
                .padding(.horizontal, 23)
                .onTapGesture {
                    hideKeyboard()
                }
                
                if isLoading {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.7))
                    .ignoresSafeArea()
                }
            }
        }
        .background(.cheekBackgroundTeritory)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $isDone, destination: {
            HomeView()
        })
    }
    
    // 키보드 숨기기
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    SetProfileMenteeView(socialProvider: .constant("Kakao"))
}
