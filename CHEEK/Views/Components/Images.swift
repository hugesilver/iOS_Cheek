//
//  Profile.swift
//  CHEEK
//
//  Created by 김태은 on 8/18/24.
//

import SwiftUI

struct ProfileBtnnav: View {
    var url: String
    
    var body: some View {
        AsyncImage(url: URL(string: url)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Image("ImageDefaultProfile")
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
        .frame(width: 25, height: 25)
        .clipShape(Circle())
    }
}

struct ProfileXS: View {
    var url: String
    
    var body: some View {
        AsyncImage(url: URL(string: url)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Image("ImageDefaultProfile")
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
        .frame(width: 32, height: 32)
        .clipShape(Circle())
    }
}

struct ProfileS: View {
    var url: String
    
    var body: some View {
        AsyncImage(url: URL(string: url)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Image("ImageDefaultProfile")
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
        .frame(width: 40, height: 40)
        .clipShape(Circle())
    }
}

struct ProfileM: View {
    var url: String
    
    var body: some View {
        AsyncImage(url: URL(string: url)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Image("ImageDefaultProfile")
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
        .frame(width: 48, height: 48)
        .clipShape(Circle())
    }
}

struct ProfileL: View {
    var url: String
    
    var body: some View {
        AsyncImage(url: URL(string: url)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Image("ImageDefaultProfile")
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
        .frame(width: 72, height: 72)
        .clipShape(Circle())
    }
}

struct ProfileXL: View {
    var url: String
    
    var body: some View {
        AsyncImage(url: URL(string: url)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Image("ImageDefaultProfile")
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
        .frame(width: 80, height: 80)
        .clipShape(Circle())
    }
}
