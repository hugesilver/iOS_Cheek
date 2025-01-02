//
//  BlockListView.swift
//  CHEEK
//
//  Created by 김태은 on 12/16/24.
//

import SwiftUI

struct BlockListView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var authViewModel: AuthenticationViewModel
    
    @StateObject private var viewModel: BlockViewModel = .init()
    @State private var showAlert: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 상단바
            HStack {
                Button(action: {
                    dismiss()}
                ) {
                    Image("IconChevronLeft")
                        .resizable()
                        .foregroundColor(.cheekTextNormal)
                        .frame(width: 32, height: 32)
                        .padding(8)
                }
                
                Spacer()
            }
            .overlay(
                Text("차단한 계정")
                    .label1(font: "SUIT", color: .cheekTextNormal, bold: true)
                , alignment: .center
            )
            .padding(.top, 8)
            .padding(.horizontal, 16)
            
            List(viewModel.blockList ?? []) { member in
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 8) {
                            ProfileS(url: member.memberDto.profilePicture)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(member.memberDto.nickname ?? "알 수 없는 사용자")
                                    .body1(font: "SUIT", color: .cheekTextNormal, bold: true)
                                    .lineLimit(1)
                            }
                            
                            Spacer()
                        }
                        
                        Text(member.memberDto.information ?? "")
                            .label2(font: "SUIT", color: .cheekTextNormal, bold: false)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: 236)
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.getblockListIndex(member.memberDto.memberId)
                        showAlert = true
                    }) {
                        ButtonNarrowHugDisabled(text: "차단 해제")
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
            authViewModel.checkRefreshTokenValid()
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("경고"),
                message: Text("해당 회원을 차단 해제하시겠습니까?"),
                primaryButton: .cancel(Text("취소")),
                secondaryButton: .default(Text("차단 해제")) {
                    viewModel.unblock()
            })
        }
    }
}

#Preview {
    BlockListView(authViewModel: AuthenticationViewModel())
}
