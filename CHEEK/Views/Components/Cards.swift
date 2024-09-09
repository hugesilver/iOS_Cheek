//
//  Cards.swift
//  CHEEK
//
//  Created by 김태은 on 8/26/24.
//

import SwiftUI

struct CaptionCard: View {
    var data: ProfileModel
    
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 8) {
                ProfileS(url: data.profilePicture)
                
                VStack(alignment: .leading) {
                    Text(data.nickname)
                        .body1(font: "SUIT", color: .cheekTextNormal, bold: true)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(data.description)
                        .caption1(font: "SUIT", color: .cheekTextAlternative, bold: false)
                        .lineLimit(1)
                }
                .frame(maxWidth: 188)
            }
            
            Text(data.information)
                .label2(font: "SUIT", color: .cheekTextNormal, bold: false)
                .lineLimit(1)
        }
        .frame(maxWidth: 236)
    }
}

struct RankingCard: View {
    var rank: Int
    var data: ProfileModel
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                Ranking(rank: rank)
                
                ProfileS(url: data.profilePicture)
                
                VStack(alignment: .leading) {
                    Text(data.nickname)
                        .body1(font: "SUIT", color: .cheekTextNormal, bold: true)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(data.description)
                        .caption1(font: "SUIT", color: .cheekTextAlternative, bold: false)
                        .lineLimit(1)
                }
                .frame(maxWidth: 188)
            }
            
            Text(data.information)
                .label2(font: "SUIT", color: .cheekTextNormal, bold: false)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(2)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12 + 16)
        .frame(maxWidth: 268)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(.cheekTextAssitive, lineWidth: 1)
                .foregroundColor(.cheekBackgroundTeritory)
        )
    }
}

struct UserFollowCard: View {
    var data: ProfileModel
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 6) {
                HStack(spacing: 8) {
                    ProfileS(url: data.profilePicture)
                    
                    VStack(alignment: .leading) {
                        Text(data.nickname)
                            .body1(font: "SUIT", color: .cheekTextNormal, bold: true)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Text("팔로워 \(10)")
                            .caption1(font: "SUIT", color: .cheekTextAlternative, bold: false)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                }
                
                Text(data.information)
                    .label2(font: "SUIT", color: .cheekTextNormal, bold: false)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(2)
            }
            .frame(maxWidth: 236)
            
            Spacer()
            
            ButtonNarrowHug(text: "팔로우")
        }
        
    }
}

struct UserCardLarge: View {
    var data: ProfileModel
    var title: String
    var date: String
    
    var body: some View {
        HStack(spacing: 8) {
            ProfileM(url: data.profilePicture)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .body1(font: "SUIT", color: .cheekTextNormal, bold: true)
                    .lineLimit(1)
                
                Text(date)
                    .label2(font: "SUIT", color: .cheekTextAlternative, bold: false)
                    .lineLimit(1)
            }
        }
    }
}

struct QuestionCard: View {
    var question: String
    
    var body: some View {
        Text(verbatim: question)
            .body1(font: "SUIT", color: .cheekTextNormal, bold: false)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(.cheekLineAlternative)
            )
    }
}

struct UserQuestionCard: View {
    var question: String
    var data: ProfileModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            UserCardLarge(data: data, title: "\(data.nickname)님의 질문입니다!", date: "\(10)일 전")
            
            QuestionCard(question: question)
        }
    }
}



struct UserAnswerCard: View {
    var answerImages: [String]
    var data: ProfileModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            UserCardLarge(data: data, title: "\(data.nickname)님의 질문입니다!", date: "\(10)일 전")
            
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(answerImages, id: \.self) { url in
                        AsyncImage(url: URL(string: url)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            Color.cheekMainNormal
                        }
                        // .aspectRatio(9/16, contentMode: .fit)
                        .frame(width: 190)
                        .frame(height: 240)
                        .clipped()
                        .cornerRadius(16)
                    }
                }
            }
        }
    }
}
