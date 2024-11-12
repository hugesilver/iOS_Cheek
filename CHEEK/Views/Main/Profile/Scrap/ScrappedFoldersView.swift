//
//  ScrapFoldersView.swift
//  CHEEK
//
//  Created by 김태은 on 10/22/24.
//

import SwiftUI

struct ScrappedFoldersView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var authViewModel: AuthenticationViewModel
    
    @StateObject var viewModel: ScrapViewModel = ScrapViewModel()
    
    @State private var myMemberId: Int64? = nil
    
    var body: some View {
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
            }
            .overlay(
                Text("스크랩된 스토리")
                    .body1(font: "SUIT", color: .cheekTextNormal, bold: true)
                , alignment: .center
            )
            .padding(.top, 8)
            .padding(.horizontal, 16)
            
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(Array(viewModel.scrappedFolders.enumerated()), id: \.offset) { index, folder in
                        VStack(spacing: 16) {
                            NavigationLink(destination: ScrappedStoriesView(authViewModel: authViewModel, scrapViewModel: viewModel, folderModel: folder)) {
                                Folder(folderModel: folder)
                            }
                            
                            if index < viewModel.scrappedFolders.count - 1 {
                                DividerSmall()
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 24)
            }
            .refreshable {
                getFolders()
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.cheekBackgroundTeritory)
        .onAppear {
            authViewModel.checkRefreshTokenValid()
            
            getFolders()
        }
    }
    
    func getFolders() {
        viewModel.getScrappedFolders()
    }
}

#Preview {
    ScrappedFoldersView(authViewModel: AuthenticationViewModel())
}
