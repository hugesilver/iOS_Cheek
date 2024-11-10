//
//  AccountPreferencesView.swift
//  CHEEK
//
//  Created by 김태은 on 10/28/24.
//

import SwiftUI

struct AccountPreferencesView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var authViewModel: AuthenticationViewModel
    @ObservedObject var profileViewModel: ProfileViewModel
    
    enum alertModeTypes {
        case logout, delete, deleted, deletedError
    }
    
    @State var alertMode: alertModeTypes = .logout
    @State var showAlert: Bool = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                // 상단바
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
                }
                .overlay(
                    Text("계정 설정")
                        .label1(font: "SUIT", color: .cheekTextNormal, bold: true)
                    , alignment: .center
                )
                .padding(.top, 8)
                .padding(.horizontal, 16)
                
                ScrollView {
                    VStack(spacing: 16) {
                        // 계정 편집
                        NavigationLink(destination: EditProfileView(authViewModel: authViewModel, profileViewModel: profileViewModel)) {
                            Text("계정 편집")
                                .title1(font: "SUIT", color: .cheekTextNormal, bold: false)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        DividerSmall()
                        
                        // 로그아웃
                        Text("로그아웃")
                            .title1(font: "SUIT", color: .cheekTextNormal, bold: false)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .onTapGesture {
                                alertMode = .logout
                                showAlert = true
                            }
                        
                        DividerSmall()
                        
                        // 관리자 페이지
                        if profileViewModel.profile != nil && profileViewModel.profile!.role == "ADMIN" {
                            NavigationLink(destination: AdminView(authViewModel: authViewModel, profileViewModel: profileViewModel)) {
                                Text("관리자 페이지")
                                    .title1(font: "SUIT", color: .cheekTextNormal, bold: false)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            DividerSmall()
                        }
                        
                        // 회원 탈퇴
                        Text("회원 탈퇴")
                            .title1(font: "SUIT", color: .cheekStatusAlert, bold: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .onTapGesture {
                                alertMode = .delete
                                showAlert = true
                            }
                       
                        
                        if profileViewModel.profile != nil && profileViewModel.profile!.role == "MENTEE" {
                            NavigationLink(destination: RequestMentorView(authViewModel: authViewModel)) {
                                ButtonActive(text: "멘토 회원 전환")
                                    .padding(.top, 8)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.cheekBackgroundTeritory)
            
            if showAlert {
                Color.cheekBlack.opacity(0.4)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.cheekBackgroundTeritory)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onAppear {
            authViewModel.checkRefreshTokenValid()
        }
        .alert(isPresented: $showAlert) {
            switch alertMode {
            case .logout:
                Alert(
                    title: Text("로그아웃 하시겠습니까?"),
                    primaryButton: .destructive(Text("네")) {
                        authViewModel.serverLogout()
                    },
                    secondaryButton: .cancel(Text("아니오"))
                )
            case .delete:
                Alert(
                    title: Text("정말 회원 탈퇴하시겠습니까?\n모든 데이터가 삭제됩니다."),
                    primaryButton: .destructive(Text("탈퇴")) {
                        deleteAccount()
                    },
                    secondaryButton: .cancel(Text("취소"))
                )
            case .deleted:
                Alert(
                    title: Text("회원 탈퇴가 완료되었습니다.\n이용해주셔서 감사합니다."),
                    dismissButton: .default(Text("확인")) {
                        authViewModel.logOut()
                    }
                )
            case .deletedError:
                Alert(
                    title: Text("회원 탈퇴 중 오류가 발생하였습니다."),
                    dismissButton: .default(Text("확인")) {
                        authViewModel.logOut()
                    }
                )
            }
        }
    }
    
    // 회원 탈퇴
    func deleteAccount() {
        authViewModel.deleteAccount() { isDone in
            if isDone {
                alertMode = .deleted
            } else {
                alertMode = .deletedError
            }
            
            showAlert = true
        }
    }
}

#Preview {
    AccountPreferencesView(authViewModel: AuthenticationViewModel(), profileViewModel: ProfileViewModel())
}
