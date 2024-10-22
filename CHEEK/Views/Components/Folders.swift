//
//  Folders.swift
//  CHEEK
//
//  Created by 김태은 on 10/22/24.
//

import SwiftUI

struct Folder: View {
    var folderModel: ScrapFolderModel
    
    var body: some View {
        HStack(spacing: 12) {
            ProfileS(url: folderModel.thumbnailPicture)
            
            Text(folderModel.folderName)
                .body2(font: "SUIT", color: .cheekTextNormal, bold: true)
            
            Spacer()
            
            Image("IconChevronRight")
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(.cheekTextNormal)
        }
    }
}
