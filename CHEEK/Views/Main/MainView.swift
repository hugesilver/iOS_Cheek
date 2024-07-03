//
//  MainView.swift
//  CHEEK
//
//  Created by 김태은 on 6/12/24.
//

import SwiftUI

struct MainView: View {
    @Binding var socialProvider: String
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    ScaledImage(name: "IconHome", size: CGSize(width: 24, height: 24))
                    Text("홈")
                }
            
            Text("Search")
                .tabItem {
                    ScaledImage(name: "IconSearch", size: CGSize(width: 24, height: 24))
                    Text("홈")
                }
            
            MypageView(socialProvider: $socialProvider)
                .tabItem {
                    ScaledImage(name: "IconMypage", size: CGSize(width: 24, height: 24))
                    Text("마이페이지")
                }
        }
    }
}

struct ScaledImage: View {
    let name: String
    let size: CGSize
    
    var body: Image {
        let uiImage = resizedImage(named: self.name, for: self.size) ?? UIImage()
        
        return Image(uiImage: uiImage.withRenderingMode(.alwaysOriginal))
    }
    
    func resizedImage(named: String, for size: CGSize) -> UIImage? {
        guard let image = UIImage(named: named) else {
            return nil
        }
        
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (context) in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

#Preview {
    MainView(socialProvider: .constant("Kakao"))
}
