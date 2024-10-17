//
//  Tabs.swift
//
//
//  Created by 김태은 on 8/19/24.
//

import SwiftUI

struct TabsText: View {
    var tabs: [String]
    @Binding var selectedTab: Int
    @State private var totalHeight = CGFloat(0)
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                let tabWidth = geometry.size.width / CGFloat(tabs.count)
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        ForEach(tabs.indices, id: \.self) { index in
                            Text(tabs[index])
                                .label1(font: "SUIT", color: selectedTab == index ? .cheekTextStrong : .cheekTextAlternative, bold:  selectedTab == index)
                                .frame(maxWidth: tabWidth)
                                .padding(.bottom, 8)
                                .background(Rectangle()
                                    .fill(.cheekBackgroundTeritory))
                                .onTapGesture {
                                    selectedTab = index
                                }
                        }
                    }
                    
                    ZStack(alignment: .bottomLeading) {
                        DividerSmall()
                        
                        Rectangle()                            .fill(.cheekMainStrong)
                            .frame(width: tabWidth, height: 4)
                            .offset(x: CGFloat(selectedTab) * tabWidth)
                            .animation(.easeInOut(duration: 0.3), value: selectedTab)
                    }
                }
                .background(GeometryReader {gp -> Color in
                    DispatchQueue.main.async {
                        self.totalHeight = gp.size.height
                    }
                    return Color.clear
                })
            }
        }
        .frame(height: totalHeight)
    }
}

struct TabsIcon: View {
    var tabs: [String]
    @Binding var selectedTab: Int
    @State private var totalHeight = CGFloat(0)
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                let tabWidth = geometry.size.width / CGFloat(tabs.count)
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        ForEach(tabs.indices, id: \.self) { index in
                            HStack {
                                Image(tabs[index])
                                    .foregroundColor(selectedTab == index ? .cheekMainStrong : .cheekTextAssitive)
                                    .frame(width: 40, height: 40)
                                    .padding(.bottom, 8)
                            }
                            .frame(maxWidth: tabWidth)
                            .background(Rectangle()
                                .fill(.cheekBackgroundTeritory))
                            .onTapGesture {
                                selectedTab = index
                            }
                        }
                    }
                    
                    ZStack(alignment: .bottomLeading) {
                        DividerSmall()
                        
                        Rectangle()                            .fill(.cheekMainStrong)
                            .frame(maxWidth: tabWidth)
                            .frame(height: 4)
                            .offset(x: CGFloat(selectedTab) * tabWidth)
                            .animation(.easeInOut(duration: 0.3), value: selectedTab)
                    }
                }
                .background(GeometryReader {gp -> Color in
                    DispatchQueue.main.async {
                        self.totalHeight = gp.size.height
                    }
                    return Color.clear
                })
            }
        }
        .frame(height: totalHeight)
    }
}

#Preview {
    TabsIcon(tabs: ["IconStory", "IconTalk"], selectedTab: .constant(0))
}
