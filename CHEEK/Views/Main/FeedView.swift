//
//  FeedView.swift
//  CHEEK
//
//  Created by 김태은 on 6/13/24.
//

import SwiftUI

struct FeedView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var search: String = ""
    
    
    @State private var isQuestion: Bool = false
    @State private var isAnswer: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    HStack {
                        Text("개발")
                            .headline1(font: "SUIT", color: .cheekTextStrong, bold: true)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .overlay(
                        Image("IconArrowLeft")
                            .frame(width: 24, height: 24)
                            .onTapGesture {
                                presentationMode.wrappedValue.dismiss()
                            }
                            .padding(.leading, 24)
                        , alignment: .leading
                    )
                    
                    Rectangle()
                        .foregroundColor(.cheekTextStrong)
                        .frame(height: 1)
                        .padding(.bottom, 16)
                    
                    VStack {
                        HStack(spacing: 8) {
                            Image("IconReadingglass")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24)
                            
                            TextField(
                                "",
                                text: $search,
                                prompt:
                                    Text("프로필, 질문, 답변으로 검색하기")
                                    .foregroundColor(.cheekTextAlternative)
                                
                            )
                            .caption1(font: "SUIT", color: .cheekTextStrong, bold: true)
                            .foregroundColor(.cheekTextStrong)
                        }
                        .padding(.horizontal, 19)
                        .frame(height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .foregroundColor(.cheekTextAssitive)
                        )
                        .padding(.bottom, 16)
                        
                        ScrollView(.horizontal) {
                            HStack(spacing: 8) {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(.cheekTextAssitive)
                                    .frame(width: 88, height: 86)
                                    .overlay(
                                        Image("IconPlus")
                                            .resizable()
                                            .renderingMode(.template)
                                            .foregroundColor(.cheekTextStrong)
                                            .frame(width: 20, height: 20)
                                    )
                                    .onTapGesture {
                                        isQuestion = true
                                    }
                                
                                FeedQuestionView(nickname: "닉네임", message: "다음주에 면접인데, 면접 때 입을 정장이 없습니다 ㅠ 정장 입고가는 거 필수일까요?")
                                
                                FeedQuestionView(nickname: "닉네임", message: "면접관에게 잘 보이는 면접 꿀팁 알려주세요!")
                                    .onTapGesture {
                                        isAnswer = true
                                    }
                                
                                FeedQuestionView(nickname: "닉네임", message: "면접관에게 잘 보이는 면접 꿀팁 알려주세요!")
                            }
                        }
                        .padding(.bottom, 24)
                        
                        /*
                        Image("ImageTempStory1")
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .overlay(
                                HStack(spacing: 8) {
                                    Circle()
                                        .foregroundColor(.cheekBackgroundTeritory)
                                        .frame(width: 34, height: 34)
                                    
                                    Text("닉네임")
                                        .caption1(font: "SUIT", color: .cheekTextStrong, bold: true)
                                    
                                }
                                    .padding(15)
                                , alignment: .topLeading
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                         */
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $isQuestion, destination: {
            AddQuestionView()
        })
        .navigationDestination(isPresented: $isAnswer, destination: {
            AddAnswerView()
        })
    }
}

struct FeedQuestionView: View {
    var nickname: String
    var message: String
    
    var body: some View {
        RoundedRectangle(cornerRadius: 5)
            .stroke(.cheekTextAlternative, lineWidth: 1)
            .frame(width: 88, height: 86)
            .overlay(
                VStack(spacing: 0) {
                    HStack(spacing: 4) {
                        Circle()
                            .foregroundColor(.cheekTextAssitive)
                            .frame(width: 12, height: 12)
                        
                        Text(nickname)
                            .font(
                                Font.custom("SUIT", size: 7)
                                    .weight(.bold)
                            )
                            .multilineTextAlignment(.center)
                            .foregroundColor(.cheekTextStrong)
                        
                        Spacer()
                    }
                    .padding(.top, 5)
                    .padding(.leading, 6)
                    
                    Text(message)
                        .font(
                            Font.custom("SUIT", size: 8)
                                .weight(.bold)
                        )
                        .multilineTextAlignment(.center)
                        .foregroundColor(.cheekTextNormal)
                        .frame(maxHeight: .infinity)
                        .padding(.horizontal, 6)
                    
                    UnevenRoundedRectangle(cornerRadii: .init(
                        topLeading: 0,
                        bottomLeading: 5,
                        bottomTrailing: 5,
                        topTrailing: 0)
                    )
                    .foregroundColor(.cheekTextAlternative)
                    .frame(height: 19)
                    .overlay(
                        HStack {
                            Text("답글 달기")
                                .font(
                                    Font.custom("SUIT", size: 7)
                                        .weight(.bold)
                                )
                                .foregroundColor(.cheekBackgroundTeritory)
                            
                            
                            Spacer()
                            
                            Text(">")
                                .font(
                                    Font.custom("SUIT", size: 7)
                                        .weight(.bold)
                                )
                                .foregroundColor(.cheekBackgroundTeritory)
                        }
                            .padding(.horizontal, 8)
                    )
                }
            )
    }
}

#Preview {
    FeedView()
}
