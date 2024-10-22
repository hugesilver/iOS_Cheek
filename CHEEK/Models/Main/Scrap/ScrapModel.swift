//
//  ScrapModel.swift
//  CHEEK
//
//  Created by 김태은 on 10/22/24.
//

import Foundation

struct ScrapFolderModel: Identifiable, Codable {
    let folderId: Int64
    let folderName: String
    let thumbnailPicture: String
    
    var id: Int64 {
        folderId
    }
}

struct CollectionModel: Identifiable, Codable, Equatable {
    let collectionId: Int64
    let storyId: Int64
    let storyPicture: String
    let modifiedAt: String
    
    var id: Int64 {
        collectionId
    }
}
