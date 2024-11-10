//
//  Profile.swift
//  CHEEK
//
//  Created by 김태은 on 8/18/24.
//

import SwiftUI
import Kingfisher

struct ProfileBtnnav: View {
    var url: String?
    
    var body: some View {
        Group {
            if let url = url {
                KFImage(URL(string: url))
                    .placeholder {
                        Image("ImageDefaultProfile")
                    }
                    .retry(maxCount: 2, interval: .seconds(2))
                    .onSuccess { result in
                        
                    }
                    .onFailure { error in
                        print("\(url) 이미지 불러오기 실패: \(error)")
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 25, height: 25)
                    .clipShape(Circle())
            } else {
                Image("ImageDefaultProfile")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 25, height: 25)
                    .clipShape(Circle())
            }
        }
    }
}

struct ProfileXS: View {
    var url: String?
    
    var body: some View {
        Group {
            if let url = url {
                KFImage(URL(string: url))
                    .placeholder {
                        Image("ImageDefaultProfile")
                    }
                    .retry(maxCount: 2, interval: .seconds(2))
                    .onSuccess { result in
                        
                    }
                    .onFailure { error in
                        print("\(url) 이미지 불러오기 실패: \(error)")
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
            } else {
                Image("ImageDefaultProfile")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
            }
        }
    }
}

struct ProfileS: View {
    var url: String?
    
    var body: some View {
        Group {
            if let url = url {
                KFImage(URL(string: url))
                    .placeholder {
                        Image("ImageDefaultProfile")
                    }
                    .retry(maxCount: 2, interval: .seconds(2))
                    .onSuccess { result in
                        
                    }
                    .onFailure { error in
                        print("\(url) 이미지 불러오기 실패: \(error)")
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            } else {
                Image("ImageDefaultProfile")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            }
        }
    }
}

struct ProfileM: View {
    var url: String?
    
    var body: some View {
        Group {
            if let url = url {
                KFImage(URL(string: url))
                    .placeholder {
                        Image("ImageDefaultProfile")
                    }
                    .retry(maxCount: 2, interval: .seconds(2))
                    .onSuccess { result in
                        
                    }
                    .onFailure { error in
                        print("\(url) 이미지 불러오기 실패: \(error)")
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
            } else {
                Image("ImageDefaultProfile")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
            }
        }
    }
}

struct ProfileL: View {
    var url: String?
    
    var body: some View {
        Group {
            if let url = url {
                KFImage(URL(string: url))
                    .placeholder {
                        Image("ImageDefaultProfile")
                    }
                    .retry(maxCount: 2, interval: .seconds(2))
                    .onSuccess { result in
                        
                    }
                    .onFailure { error in
                        print("\(url) 이미지 불러오기 실패: \(error)")
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 72, height: 72)
                    .clipShape(Circle())
            } else {
                Image("ImageDefaultProfile")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 72, height: 72)
                    .clipShape(Circle())
            }
        }
    }
}

struct ProfileXL: View {
    var url: String?
    
    var body: some View {
        Group {
            if let url = url {
                KFImage(URL(string: url))
                    .placeholder {
                        Image("ImageDefaultProfile")
                    }
                    .retry(maxCount: 2, interval: .seconds(2))
                    .onSuccess { result in
                        
                    }
                    .onFailure { error in
                        print("\(url) 이미지 불러오기 실패: \(error)")
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
            } else {
                Image("ImageDefaultProfile")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
            }
        }
    }
}
