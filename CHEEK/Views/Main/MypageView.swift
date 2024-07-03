//
//  MypageView.swift
//  CHEEK
//
//  Created by 김태은 on 6/12/24.
//

import SwiftUI

struct MypageView: View {
    @Binding var socialProvider: String
    
    var gridColumns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 0), count: 3)
    
    @State private var selectedTab = 0
    @State private var height: CGFloat = 0
    
    @State private var profileModel: ProfileModel?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    Text("닉네임")
                        .title1(font: "SUIT", color: .cheekTextStrong, bold: true)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 24)
                    
                    HStack(spacing: 18) {
                        /*
                         if let profile = profile_image, profile != "" {
                         AsyncImage(url: URL(string: profile)) {
                         image in image.resizable()
                         } placeholder: {
                         Color("MOCDarkGray")
                         }
                         .aspectRatio(contentMode: .fill)
                         .clipShape(Circle())
                         .frame(width: 96, height: 96)
                         } else {
                         */
                        Circle()
                            .foregroundColor(.cheekTextAssitive)
                            .frame(width: 96, height: 96)
                        
                        // }
                        
                        HStack {
                            VStack(spacing: 4) {
                                Text("109")
                                    .label1(font: "SUIT", color: .cheekTextStrong, bold: true)
                                    .multilineTextAlignment(.center)
                                
                                Text("스토리")
                                    .label1(font: "SUIT", color: .cheekTextStrong, bold: true)
                                    .multilineTextAlignment(.center)
                            }
                            
                            Spacer()
                            
                            VStack(spacing: 4) {
                                Text("2,509")
                                    .label1(font: "SUIT", color: .cheekTextStrong, bold: true)
                                    .multilineTextAlignment(.center)
                                
                                Text("팔로워")
                                    .label1(font: "SUIT", color: .cheekTextStrong, bold: true)
                                    .multilineTextAlignment(.center)
                            }
                            
                            Spacer()
                            
                            VStack(spacing: 4) {
                                Text("54")
                                    .label1(font: "SUIT", color: .cheekTextStrong, bold: true)
                                    .multilineTextAlignment(.center)
                                
                                Text("팔로잉")
                                    .label1(font: "SUIT", color: .cheekTextStrong, bold: true)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(.horizontal, 18)
                    }
                    .padding(.bottom, 12)
                    
                    HStack {
                        Text("직무 한줄소개")
                            .caption1(font: "SUIT", color: .cheekTextStrong, bold: true)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 5)
                            .background(.cheekBackgroundPrimary)
                        
                        Spacer()
                    }
                    .padding(.bottom, 8)
                    
                    Rectangle()
                        .frame(maxWidth: .infinity)
                        .frame(height: 45)
                        .foregroundColor(.cheekBackgroundPrimary)
                        .overlay(
                            Text("자기소개")
                                .caption1(font: "SUIT", color: .cheekTextStrong, bold: true)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 5)
                            , alignment: .topLeading
                        )
                        .padding(.bottom, 8)
                    
                    RoundedRectangle(cornerRadius: 5)
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                        .foregroundColor(.cheekTextAssitive)
                        .overlay(
                            Text("프로필 편집")
                                .caption1(font: "SUIT", color: .cheekTextStrong, bold: true)
                        )
                        .padding(.bottom, 16)
                    
                    ScrollView(.horizontal) {
                        HStack(alignment: .top, spacing: 12) {
                            Circle()
                                .foregroundColor(.cheekTextAssitive)
                                .frame(width: 63, height: 63)
                            
                            Circle()
                                .foregroundColor(.cheekTextAssitive)
                                .frame(width: 63, height: 63)
                            
                            VStack(spacing: 4) {
                                Circle()
                                    .stroke(.cheekTextAssitive, lineWidth: 1)
                                    .frame(width: 63, height: 63)
                                    .overlay(
                                        Image("IconPlus")
                                            .resizable()
                                            .renderingMode(.template)
                                            .foregroundColor(.cheekTextStrong)
                                            .frame(width: 28, height: 28)
                                    )
                                
                                Text("프로필 편집")
                                    .caption1(font: "SUIT", color: .cheekTextStrong, bold: false)
                            }
                        }
                    }
                    .padding(.bottom, 16)
                    
                    Rectangle()
                        .stroke(.cheekTextAssitive, lineWidth: 1)
                        .frame(maxWidth: .infinity)
                        .frame(height: 23)
                        .overlay(
                            Text("스크랩한 스토리 보기")
                                .caption1(font: "SUIT", color: .cheekTextStrong, bold: false)
                        )
                        .padding(.bottom, 16)
                    
                    GeometryReader { geometry in
                        VStack(spacing: 0) {
                            HStack(spacing: 0) {
                                Text("스토리")
                                    .caption1(font: "SUIT", color: selectedTab == 0 ? .cheekTextStrong : .cheekTextAlternative, bold: true)
                                    .frame(maxWidth: geometry.size.width / 2)
                                    .onTapGesture {
                                        selectedTab = 0
                                    }
                                
                                Text("질문")
                                    .caption1(font: "SUIT", color: selectedTab == 1 ? .cheekTextStrong : .cheekTextAlternative, bold: true)
                                    .frame(maxWidth: geometry.size.width / 2)
                                    .onTapGesture {
                                        selectedTab = 1
                                    }
                            }
                            .padding(.bottom, 8)
                            
                            Rectangle()
                                .foregroundColor(.cheekLineAlternative)
                                .frame(height: 0.5)
                                .overlay(
                                    HStack(spacing: 0) {
                                        Rectangle()
                                            .foregroundColor(.cheekTextStrong)
                                            .frame(width: geometry.size.width / 2)
                                            .frame(height: 0.5)
                                            .padding(.leading, selectedTab == 0 ?
                                                     0 :
                                                        geometry.size.width / CGFloat((selectedTab + 1)))
                                            .animation(.spring(), value: selectedTab)
                                        
                                        Spacer()
                                    }
                                )
                            
                            TabView(selection: $selectedTab) {
                                LazyVGrid(columns: gridColumns, spacing: 0) {
                                    Rectangle()
                                        .foregroundColor(.cheekBackgroundPrimary)
                                        .frame(height: 206)
                                        .overlay(
                                            Rectangle()
                                                .stroke(.cheekTextAlternative, lineWidth: 0.5)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 3)
                                                .foregroundColor(.cheekBackgroundTeritory)
                                                .frame(width: 27, height: 26)
                                                .padding(7)
                                                .overlay(
                                                    Text("5/31")
                                                        .caption1(font: "SUIT", color: .cheekTextStrong, bold: true)
                                                )
                                            , alignment: .topLeading
                                        )
                                    
                                    Rectangle()
                                        .foregroundColor(.cheekBackgroundPrimary)
                                        .frame(height: 206)
                                        .overlay(
                                            Rectangle()
                                                .stroke(.cheekTextAlternative, lineWidth: 0.5)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 3)
                                                .foregroundColor(.cheekBackgroundTeritory)
                                                .frame(width: 27, height: 26)
                                                .padding(7)
                                                .overlay(
                                                    Text("5/14")
                                                        .caption1(font: "SUIT", color: .cheekTextStrong, bold: true)
                                                )
                                            , alignment: .topLeading
                                        )
                                    
                                    Rectangle()
                                        .foregroundColor(.cheekBackgroundPrimary)
                                        .frame(height: 206)
                                        .overlay(
                                            Rectangle()
                                                .stroke(.cheekTextAlternative, lineWidth: 0.5)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 3)
                                                .foregroundColor(.cheekBackgroundTeritory)
                                                .frame(width: 27, height: 26)
                                                .padding(7)
                                                .overlay(
                                                    Text("3/2")
                                                        .caption1(font: "SUIT", color: .cheekTextStrong, bold: true)
                                                )
                                            , alignment: .topLeading
                                        )
                                }
                                .frame(maxHeight: .infinity, alignment: .top)
                                .tag(0)
                                .background(
                                    GeometryReader { geo in
                                        Color.clear
                                            .preference(
                                                key: HeightPreferenceKey.self,
                                                value: geo.size.height
                                            )
                                    }
                                        .onPreferenceChange(HeightPreferenceKey.self) { height in
                                            self.height = height
                                        }
                                )
                                
                                LazyVGrid(columns: gridColumns, spacing: 0) {
                                    Rectangle()
                                        .stroke(.cheekTextAlternative, lineWidth: 1)
                                        .frame(height: geometry.size.width / 3)
                                        .overlay(
                                            Text("다음주에 면접인데,면접 때 입을 정장이 없습니다 ㅠ 정장 입고 가는 거 필수일까요?")
                                                .caption1(font: "SUIT", color: .cheekTextStrong, bold: true)
                                                .multilineTextAlignment(.center)
                                                .padding(10)
                                        )
                                    
                                    Rectangle()
                                        .stroke(.cheekTextAlternative, lineWidth: 1)
                                        .frame(height: geometry.size.width / 3)
                                        .overlay(
                                            Text("연봉이 높은 회사하고 복지가 좋은 회사 중에 다들 어떤 회사가 더 좋다고 생각하나요?")
                                                .caption1(font: "SUIT", color: .cheekTextStrong, bold: true)
                                                .multilineTextAlignment(.center)
                                                .padding(10)
                                        )
                                    
                                    Rectangle()
                                        .stroke(.cheekTextAlternative, lineWidth: 1)
                                        .frame(height: geometry.size.width / 3)                                        .overlay(
                                            Text("요즘 개발에 권태기가 온 개발자입니다 이럴 땐 어떻게 극복할까요")
                                                .caption1(font: "SUIT", color: .cheekTextStrong, bold: true)
                                                .multilineTextAlignment(.center)
                                                .padding(10)
                                        )
                                    
                                    Rectangle()
                                        .stroke(.cheekTextAlternative, lineWidth: 1)
                                        .frame(height: geometry.size.width / 3)                                        .overlay(
                                            Text("포트폴리오를 눈에 잘 띄게 구성할 수 있는 방법은 뭘까용??")
                                                .caption1(font: "SUIT", color: .cheekTextStrong, bold: true)
                                                .multilineTextAlignment(.center)
                                                .padding(10)
                                        )
                                    
                                    Rectangle()
                                        .stroke(.cheekTextAlternative, lineWidth: 1)
                                        .frame(height: geometry.size.width / 3)                                        .overlay(
                                            Text("면접관에게 잘 보이는 면접 꿀팁 알려주세요!")
                                                .caption1(font: "SUIT", color: .cheekTextStrong, bold: true)
                                                .multilineTextAlignment(.center)
                                                .padding(10)
                                        )
                                    
                                    Rectangle()
                                        .stroke(.cheekTextAlternative, lineWidth: 1)
                                        .frame(height: geometry.size.width / 3)                                        .overlay(
                                            Text("스타트업 vs 대기업 장단점과 연봉 차이가 많이 나는지 궁금해요")
                                                .caption1(font: "SUIT", color: .cheekTextStrong, bold: true)
                                                .multilineTextAlignment(.center)
                                                .padding(10)
                                        )
                                }
                                .frame(maxHeight: .infinity, alignment: .top)
                                .tag(1)
                                .background(
                                    GeometryReader { geo in
                                        Color.clear
                                            .preference(
                                                key: HeightPreferenceKey.self,
                                                value: geo.size.height
                                            )
                                    }
                                        .onPreferenceChange(HeightPreferenceKey.self) { height in
                                            self.height = height
                                        }
                                )
                            }
                            .tabViewStyle(.page)
                            .frame(height: height)
                            .animation(.easeOut(duration: 0.2), value: selectedTab)
                            .transition(.slide)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
            }
        }
        .onAppear {
            UIPageControl.appearance().currentPageIndicatorTintColor = .clear
            UIPageControl.appearance().pageIndicatorTintColor = .clear
            
            
        }
    }
}

struct HeightPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    MypageView(socialProvider: .constant("Kakao"))
}
