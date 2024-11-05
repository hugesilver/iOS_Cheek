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
        case logout, delete
    }
    
    @State var alertMode: alertModeTypes = .logout
    @State var showAlert: Bool = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                // 상단바
                HStack {
                    Image("IconChevronLeft")
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
                        .title1(font: "SUIT", color: .cheekTextNormal, bold: true)
                    , alignment: .center
                )
                .padding(.top, 8)
                .padding(.horizontal, 16)
                
                ScrollView {
                    VStack(spacing: 16) {
                        NavigationLink(destination: EditProfileView(authViewModel: authViewModel, profileViewModel: profileViewModel)) {
                            Text("계정 편집")
                                .title1(font: "SUIT", color: .cheekTextNormal, bold: false)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        DividerSmall()
                        
                        Text("로그아웃")
                            .title1(font: "SUIT", color: .cheekTextNormal, bold: false)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .onTapGesture {
                                alertMode = .logout
                                showAlert = true
                            }
                        
                        DividerSmall()
                        
                        Text("회원 탈퇴")
                            .title1(font: "SUIT", color: .cheekStatusAlert, bold: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
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
            authViewModel.isRefreshTokenValid = authViewModel.checkRefreshTokenValid()
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
                    title: Text("정말 회원 탈퇴하시겠습니까?"),
                    primaryButton: .destructive(Text("네")) {
                        
                    },
                    secondaryButton: .cancel(Text("아니오"))
                )
            }
        }
    }
}

#Preview {
    AccountPreferencesView(authViewModel: AuthenticationViewModel(), profileViewModel: ProfileViewModel())
}
