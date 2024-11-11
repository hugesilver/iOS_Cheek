//
//  AdminView.swift
//  CHEEK
//
//  Created by 김태은 on 11/7/24.
//

import SwiftUI

struct AdminView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var stateViewModel: StateViewModel
    @ObservedObject var profileViewModel: ProfileViewModel
    
    @StateObject var viewModel: AdminViewModel = AdminViewModel()
    
    @State var showAlert: Bool = false
    @State var selectedMember: AdminMemberInfoModel?
    @State var selectedRole: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
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
                Text("관리자 페이지")
                    .label1(font: "SUIT", color: .cheekTextNormal, bold: true)
                , alignment: .center
            )
            .padding(.top, 8)
            .padding(.horizontal, 16)
            
            List(viewModel.memberList) { member in
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(member.nickname ?? "null")
                            .body1(font: "SUIT", color: .cheekTextNormal, bold: true)
                        
                        Text(member.email)
                            .label2(font: "SUIT", color: .cheekTextNormal, bold: false)
                        
                        Text(member.role ?? "null")
                            .label2(font: "SUIT", color: .cheekTextNormal, bold: false)
                    }
                    
                    Spacer()
                    
                    Menu {
                        Button(action: {
                            selectedMember = member
                            selectedRole = "MENTOR"
                            showAlert = true
                        }) {
                            Text("MENTOR")
                        }
                        
                        Button(action: {
                            selectedMember = member
                            selectedRole = "MENTEE"
                            showAlert = true
                        }) {
                            Text("MENTEE")
                        }
                        
                        Button(action: {
                            selectedMember = member
                            selectedRole = "ADMIN"
                            showAlert = true
                        }) {
                            Text("ADMIN")
                        }
                        
                        Button(action: {
                            selectedMember = member
                            selectedRole = "REJECTED"
                            showAlert = true
                        }) {
                            Text("REJECTED")
                        }
                        
                    } label: {
                        Image("IconMore")
                            .resizable()
                            .foregroundColor(.cheekTextAlternative)
                            .frame(width: 32, height: 32)
                    }
                }
                .padding(16)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
                .frame(maxWidth: .infinity)
                .background(.cheekBackgroundTeritory)
            }
            .listStyle(.plain)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.cheekBackgroundTeritory)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onAppear {
            stateViewModel.checkRefreshTokenValid()
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("\(selectedMember?.nickname ?? "")의 역할을 \(selectedRole)으로 변경하시겠습니까?"),
                primaryButton: .destructive(Text("변경")) {
                    changeMemberRole()
                },
                secondaryButton: .cancel(Text("취소"))
            )
        }
    }
    
    func changeMemberRole() {
        if profileViewModel.profile != nil &&
            profileViewModel.profile!.role == "ADMIN" &&
            selectedMember != nil &&
            selectedRole != "" {
            viewModel.changeMemberRole(memberId: selectedMember!.memberId, role: selectedRole)
            
            // 만약 자기 자신을 변경했을 경우
            if profileViewModel.profile!.memberId == selectedMember!.memberId {
                profileViewModel.profile!.role = selectedRole
                
                // 뒤로가기
                DispatchQueue.main.async {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    AdminView(stateViewModel: StateViewModel(), profileViewModel: ProfileViewModel())
}
