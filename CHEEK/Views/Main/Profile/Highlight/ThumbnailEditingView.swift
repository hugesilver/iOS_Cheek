//
//  HighlightCropView.swift
//  CHEEK
//
//  Created by 김태은 on 10/17/24.
//

import SwiftUI
import PhotosUI
import Kingfisher

fileprivate let ratio: CGFloat = 0.814
fileprivate let size: CGSize = .init(width: UIScreen.main.bounds.width * ratio, height: UIScreen.main.bounds.width * ratio)
fileprivate let frameVerticalPadding: CGFloat = 40

struct ThumbnailEditingView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var highlightViewModel: HighlightViewModel
    
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var lastStoredOffset: CGSize = .zero
    @State private var isInteracting: Bool = false
    
    @State private var photosPickerItem: PhotosPickerItem?
    @State private var showPhotosPicker: Bool = false
    
    @State private var selectedThumbnail: StoryDto? = nil
    
    @State private var isSaving: Bool = false
    
    @State private var showAlert: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image("IconChevronLeft")
                    .foregroundColor(.cheekTextNormal)
                    .frame(width: 32, height: 32)
                    .onTapGesture {
                        dismiss()
                    }
                    .padding(8)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text("확인")
                        .label1(font: "SUIT", color: .cheekTextNormal, bold: false)
                }
                .padding(.horizontal, 11)
                .onTapGesture {
                    if highlightViewModel.selectedImage != nil {
                        isSaving = true
                        
                        let renderer = ImageRenderer(content: ThumbnailView())
                        renderer.proposedSize = .init(size)
                        
                        if let image = renderer.uiImage {
                            highlightViewModel.thumbnail = image
                        }
                        
                        dismiss()
                    } else {
                        showAlert = true
                    }
                }
            }
            .overlay(
                Text("스토리 선택")
                    .title1(font: "SUIT", color: .cheekTextNormal, bold: true)
                , alignment: .center
            )
            .padding(.top, 8)
            .padding(.horizontal, 16)
            
            ScrollView {
                VStack(spacing: 0) {
                    ZStack {
                        ThumbnailBackgroundView()
                            .frame(width: UIScreen.main.bounds.width, height: size.height)
                            .padding(.vertical, frameVerticalPadding)
                            .blur(radius: 4)
                            .overlay(
                                Color(red: 0.29, green: 0.29, blue: 0.29).opacity(0.6)
                            )
                        
                        ThumbnailView()
                            .frame(
                                width: size.width,
                                height: size.height
                            )
                    }
                    .clipped()
                    
                    ScrollView(.horizontal) {
                        HStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 16)
                                .frame(width: 160, height: 240)
                                .foregroundColor(.cheekLineNormal)
                                .overlay(
                                    VStack(spacing: 4) {
                                        Image("IconPhotograph")
                                            .resizable()
                                            .frame(width: 32, height: 32)
                                            .foregroundColor(.cheekTextAlternative)
                                        
                                        Text("앨범에서 이미지 찾기")
                                            .caption1(font: "SUIT", color: .cheekTextAlternative, bold: false)
                                    }
                                )
                                .onTapGesture {
                                    showPhotosPicker = true
                                }
                                .photosPicker(isPresented: $showPhotosPicker, selection: $photosPickerItem)
                                .onChange(of: photosPickerItem) { image in
                                    Task {
                                        guard let data = try? await image?.loadTransferable(type: Data.self) else { return }
                                        
                                        highlightViewModel.selectedImage = UIImage(data: data)
                                    }
                                    
                                    photosPickerItem = nil
                                }
                            
                            ForEach(highlightViewModel.selectedStories) { story in
                                KFImage(URL(string: story.storyPicture))
                                    .placeholder {
                                        Color.cheekLineAlternative
                                    }
                                    .retry(maxCount: 2, interval: .seconds(2))
                                    .onSuccess { result in
                                        
                                    }
                                    .onFailure { error in
                                        print("이미지 불러오기 실패: \(error)")
                                    }
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 160, height: 240)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .strokeBorder(.cheekMainNormal, lineWidth: selectedThumbnail != nil && selectedThumbnail!.storyId == story.storyId ? 4 : 0)
                                    )
                                    .onTapGesture {
                                        selectedThumbnail = story
                                        
                                        highlightViewModel.convertUIImage(url: story.storyPicture)
                                    }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.top, 49)
                    .padding(.bottom, 32)
                    
                    Spacer()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .background(.cheekBackgroundTeritory)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("오류"),
                message: Text("썸네일을 선택해주세요!")
            )
        }
    }
    
    /// - Thumb View
    @ViewBuilder
    func ThumbnailView() -> some View {
        GeometryReader {
            let size = $0.size
            
            if highlightViewModel.selectedImage != nil {
                Image(uiImage: highlightViewModel.selectedImage!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .overlay(content: {
                        GeometryReader { proxy in
                            let rect = proxy.frame(in: .named("CROPVIEW"))
                            
                            Color.clear
                                .onChange(of: isInteracting) { newValue in
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        if rect.minX > 0 {
                                            offset.width = (offset.width - rect.minX)
                                        }
                                        
                                        if rect.minY > 0 {
                                            offset.height = (offset.height - rect.minY)
                                        }
                                        
                                        if rect.maxX < size.width {
                                            offset.width = (rect.minX - offset.width)
                                        }
                                        
                                        if rect.maxY < size.height {
                                            offset.height = (rect.minY - offset.height)
                                        }
                                    }
                                    
                                    
                                    if !newValue {
                                        lastStoredOffset = offset
                                    }
                                }
                        }
                    })
            }
        }
        .scaleEffect(scale * (UIScreen.main.bounds.width / (UIScreen.main.bounds.width * ratio)))
        .offset(offset)
        .coordinateSpace(name: "CROPVIEW")
        .gesture(
            DragGesture()
                .onChanged({ value in
                    isInteracting = true
                    let translation = value.translation
                    offset = CGSize(
                        width: translation.width + lastStoredOffset.width,
                        height: translation.height + lastStoredOffset.height
                    )
                })
                .onEnded({ _ in
                    isInteracting = false
                    lastStoredOffset = offset
                })
        )
        .gesture(
            MagnificationGesture()
                .onChanged({ value in
                    isInteracting = true
                    let updatedScale = value + lastScale
                    
                    scale = (updatedScale < 1 ? 1 : updatedScale)
                })
                .onEnded({ value in
                    isInteracting = false
                    withAnimation(.easeInOut(duration: 0.2)) {
                        if scale < 1 {
                            scale = 1
                            lastScale = 0
                        } else {
                            lastScale = scale - 1
                        }
                    }
                })
        )
        .frame(width: size.width, height: size.height)
        .cornerRadius(size.height / 2)
    }
    
    /// - Thumbnail Background View
    @ViewBuilder
    func ThumbnailBackgroundView() -> some View {
        GeometryReader { _ in
            if let selectedImage = highlightViewModel.selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
        }
        .scaleEffect(thumbnailBackgroundScaleEffect(image: highlightViewModel.selectedImage))
        .offset(x: thumbnailBackgroundXOffset(image: highlightViewModel.selectedImage),
                y: thumbnailBackgroundYOffset(image: highlightViewModel.selectedImage))
    }

    // 썸네일 배경 ScaleEffect 계산
    private func thumbnailBackgroundScaleEffect(image: UIImage?) -> CGFloat {
        guard let image = image else { return scale }
        
        return image.size.width > image.size.height ? scale * (UIScreen.main.bounds.width / (UIScreen.main.bounds.width * ratio)) : scale
    }

    // 썸네일 배경 X Offset
    private func thumbnailBackgroundXOffset(image: UIImage?) -> CGFloat {
        guard let image = image else { return offset.width }
        
        let imageAspectRatio = image.size.width / image.size.height
        let viewAspectRatio = (UIScreen.main.bounds.width + frameVerticalPadding) / UIScreen.main.bounds.width
        
        if imageAspectRatio > 1 {
            return offset.width + (UIScreen.main.bounds.width - size.width) / ((1 + ratio) - (viewAspectRatio - 1))
        }
        
        return offset.width
    }

    // 썸네일 배경 Y Offset
    private func thumbnailBackgroundYOffset(image: UIImage?) -> CGFloat {
        guard let image = image else { return offset.height }
        
        let imageAspectRatio = image.size.width / image.size.height
        let viewAspectRatio = (UIScreen.main.bounds.width + frameVerticalPadding) / UIScreen.main.bounds.width
        
        if imageAspectRatio <= 1 {
            return offset.height - (UIScreen.main.bounds.width - size.height) / ((viewAspectRatio + ratio) + (viewAspectRatio - 1))
        }
        
        return offset.height
    }
}

#Preview {
    ThumbnailEditingView(highlightViewModel: HighlightViewModel())
}
