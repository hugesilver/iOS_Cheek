//
//  AddStoryView.swift
//  CHEEK
//
//  Created by 김태은 on 6/13/24.
//

import SwiftUI
import PhotosUI

struct AddAnswerView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject var viewModel = AddAnswerViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    Text("취소")
                        .label2(font: "SUIT", color: .cheekTextStrong, bold: true)
                        .padding(.leading, 24)
                        .onTapGesture {
                            presentationMode.wrappedValue.dismiss()
                        }
                    
                    Spacer()
                }
                
                ZStack {
                    // 캔버스
                    AnswerDrawingView(viewModel: viewModel)
                    
                    // 메뉴
                    AddAnswerMenusView(viewModel: viewModel)
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity,
                            alignment: .topTrailing)
                    
                    // 그리기 팔레트
                    if viewModel.userInteractState == .draw {
                        DrawPaletteView(viewModel: viewModel)
                            .frame(maxHeight: .infinity, alignment: .bottom)
                    }
                    
                    // 배경색 팔레트
                    if viewModel.userInteractState == .backgroundColor {
                        BackgroundColorPaletteView(viewModel: viewModel)
                            .frame(maxHeight: .infinity, alignment: .bottom)
                    }
                    
                    // 텍스트 추가
                    if viewModel.addTextObject {
                        AddTextObjectView(viewModel: viewModel)
                    }
                    
                    // 텍스트 수정
                    if viewModel.editTextObject {
                        EditTextObjectView(viewModel: viewModel)
                    }
                }
                .onChange(of: viewModel.userInteractState) { value in
                    if viewModel.userInteractState == .draw {
                        viewModel.canvas.isUserInteractionEnabled = true
                    } else {
                        viewModel.canvas.isUserInteractionEnabled = false
                    }
                }
                .frame(
                    width: UIScreen.main.bounds.size.width,
                    height: ((UIScreen.main.bounds.size.width / 9) * 16)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .onAppear {
                    // 질문 오브젝트 추가
                    viewModel.stackItems.append(
                        AnswerStackModel(
                            type: "question",
                            view:
                                AnyView(
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(.cheekTextAssitive)
                                        .frame(width: 264, height: 202)
                                        .overlay(
                                            VStack(spacing: 0) {
                                                VStack {
                                                    Text("질문")
                                                        .label2(font: "SUIT", color: .cheekTextStrong, bold: true)
                                                        .padding(.bottom, 15)
                                                    
                                                    Text("Test")
                                                        .font(
                                                            Font.custom("SUIT", size: 8.5)
                                                                .weight(.bold)
                                                        )
                                                        .multilineTextAlignment(.center)
                                                        .foregroundColor(.cheekTextStrong)
                                                        .padding(.horizontal, 10)
                                                        .frame(height: 69)
                                                        .frame(maxWidth: .infinity)
                                                        .background(
                                                            RoundedRectangle(cornerRadius: 5)
                                                                .foregroundColor(.cheekBackgroundTeritory)
                                                        )
                                                        .padding(.horizontal, 20)
                                                    
                                                }
                                                .frame(maxHeight: .infinity)
                                                .padding(.top, 44)
                                            }
                                        )
                                        .overlay(
                                            Circle()
                                                .foregroundColor(.cheekTextAlternative)
                                                .frame(width: 62, height: 62)
                                                .alignmentGuide(.top) { $0[VerticalAlignment.center] }
                                            , alignment: .top
                                        )
                                    
                                )
                        )
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
}

// 텍스트 팔레트
struct TextPaletteView: View {
    @ObservedObject var viewModel: AddAnswerViewModel
    let colors: [Color] = [.white, .black, .red, .yellow, .green, .blue, .purple]
    
    var body: some View {
        VStack(spacing: 10) {
            Slider(value: $viewModel.stackItems[viewModel.currentIndex].fontSize, in: 15...30, step: 0.1)
                .frame(width: (20 * CGFloat(colors.count)) + (10 * (CGFloat(colors.count) - 1)))
            
            HStack(spacing: 10) {
                ForEach(colors, id: \.self) { color in
                    Circle()
                        .frame(width: 20, height: 20)
                        .foregroundColor(color)
                        .onTapGesture {
                            viewModel.stackItems[viewModel.currentIndex].textColor = color
                        }
                }
            }
        }
    }
    
}

// 그리기 팔레트
struct DrawPaletteView: View {
    @ObservedObject var viewModel: AddAnswerViewModel
    let colors: [Color] = [.white, .black, .red, .yellow, .green, .blue, .purple]
    
    var body: some View {
        VStack(spacing: 10) {
            Slider(value: $viewModel.inkWidth, in: 2...15, step: 1)
                .frame(width: (20 * CGFloat(colors.count)) + (10 * (CGFloat(colors.count) - 1)))
            
            HStack(spacing: 10) {
                ForEach(colors, id: \.self) { color in
                    Circle()
                        .frame(width: 20, height: 20)
                        .foregroundColor(color)
                        .onTapGesture {
                            viewModel.isDraw = true
                            viewModel.inkColor = color
                        }
                }
                
                Image(systemName: "eraser")
                    .onTapGesture {
                        viewModel.isDraw = false
                    }
            }
        }
    }
}

// 배경색 팔레트
struct BackgroundColorPaletteView: View {
    @ObservedObject var viewModel: AddAnswerViewModel
    let colors: [Color] = [.white, .black, .red, .yellow, .green, .blue, .purple]
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(colors, id: \.self) { color in
                Circle()
                    .frame(width: 20, height: 20)
                    .foregroundColor(color)
                    .onTapGesture {
                        viewModel.frameBackgroundColor = color
                    }
            }
        }
    }
}

// 메뉴
struct AddAnswerMenusView: View {
    @ObservedObject var viewModel: AddAnswerViewModel
    @State private var photosPickerItem: PhotosPickerItem?
    @State private var showPhotosPicker: Bool = false
    
    var body: some View {
        VStack(spacing: 16) {
            // 텍스트
            Circle()
                .foregroundColor(.cheekTextAssitive)
                .frame(width: 42, height: 42)
                .overlay(
                    Text("텍스트")
                        .font(
                            Font.custom("SUIT", size: 10)
                                .weight(.bold)
                        )
                        .multilineTextAlignment(.center)
                        .foregroundColor(.cheekTextStrong)
                )
                .onTapGesture {
                    viewModel.userInteractState = .text
                    viewModel.addTextObject = true
                    
                    viewModel.canvas.resignFirstResponder()
                    
                    viewModel.stackItems.append(
                        AnswerStackModel(type: "text")
                    )
                    viewModel.currentIndex = viewModel.stackItems.count - 1
                }
            
            // 그리기
            Circle()
                .foregroundColor(.cheekTextAssitive)
                .frame(width: 42, height: 42)
                .overlay(
                    Text("그리기")
                        .font(
                            Font.custom("SUIT", size: 10)
                                .weight(.bold)
                        )
                        .multilineTextAlignment(.center)
                        .foregroundColor(.cheekTextStrong)
                )
                .onTapGesture {
                    viewModel.userInteractState = .draw
                }
            
            // 사진
            Circle()
                .foregroundColor(.cheekTextAssitive)
                .frame(width: 42, height: 42)
                .overlay(
                    Text("사진")
                        .font(
                            Font.custom("SUIT", size: 10)
                                .weight(.bold)
                        )
                        .multilineTextAlignment(.center)
                        .foregroundColor(.cheekTextStrong)
                )
                .onTapGesture {
                    showPhotosPicker = true
                    viewModel.userInteractState = .image
                }
                .photosPicker(isPresented: $showPhotosPicker, selection: $photosPickerItem)
                .onChange(of: photosPickerItem) { image in
                    Task {
                        guard let data = try? await image?.loadTransferable(type: Data.self) else { return }
                        
                        viewModel.stackItems.append(
                            AnswerStackModel(
                                type: "image",
                                view:
                                    AnyView(
                                        Image(uiImage: UIImage(data: data)!)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: (UIScreen.main.bounds.size.width) / 2)
                                    )
                            )
                        )
                    }
                    
                    photosPickerItem = nil
                }
            
            // 배경색
            Circle()
                .foregroundColor(.cheekTextAssitive)
                .frame(width: 42, height: 42).overlay(
                    Text("배경색")
                        .font(
                            Font.custom("SUIT", size: 10)
                                .weight(.bold)
                        )
                        .multilineTextAlignment(.center)
                        .foregroundColor(.cheekTextStrong)
                )
                .onTapGesture {
                    viewModel.userInteractState = .backgroundColor
                }
            
            // 저장(임시)
            Circle()
                .foregroundColor(.cheekTextAssitive)
                .frame(width: 42, height: 42).overlay(
                    Text("저장")
                        .font(
                            Font.custom("SUIT", size: 10)
                                .weight(.bold)
                        )
                        .multilineTextAlignment(.center)
                        .foregroundColor(.cheekTextStrong)
                )
                .onTapGesture {
                    viewModel.userInteractState = .save
                    
                    viewModel.saveCanvasImage() {
                        AnswerDrawingView(viewModel: viewModel)
                    }
                }
        }
        .padding(.top, 28)
        .padding(.trailing, 16)
    }
}

// 텍스트 추가
struct AddTextObjectView: View {
    @ObservedObject var viewModel: AddAnswerViewModel
    @FocusState private var isFieldFocused: Bool
    
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.75)
            
            TextField(
                "",
                text: $viewModel.stackItems[viewModel.currentIndex].text,
                prompt:
                    Text("텍스트를 입력하세요.")
                    .foregroundColor(viewModel.stackItems[viewModel.currentIndex].textColor),
                axis: .vertical
            )
            .font(
                .custom("SUIT", size: viewModel.stackItems[viewModel.currentIndex].fontSize)
            )
            .foregroundColor(viewModel.stackItems[viewModel.currentIndex].textColor)
            .fontWeight(
                viewModel.stackItems[viewModel.currentIndex].isBold ?
                    .bold : .regular
            )
            .lineLimit(nil)
            .padding(.leading, 24)
            .focused($isFieldFocused)
            .autocorrectionDisabled()
            .onSubmit {
                viewModel.stackItems[viewModel.currentIndex].text += "\n"
                isFieldFocused = true
            }
            
            HStack {
                Text("취소")
                    .label2(font: "SUIT", color: .cheekBackgroundTeritory, bold: true)
                    .onTapGesture {
                        viewModel.cancelTextView()
                    }
                
                Spacer()
                
                Text("추가")
                    .label2(font: "SUIT", color: .cheekBackgroundTeritory, bold: true)
                    .onTapGesture {
                        viewModel.addTextObject = false
                        viewModel.canvas.becomeFirstResponder()
                    }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .frame(maxHeight: .infinity, alignment: .top)
            
            TextPaletteView(viewModel: viewModel)
                .frame(maxHeight: .infinity, alignment: .bottom)
        }
    }
}

// 텍스트 수정
struct EditTextObjectView: View {
    @ObservedObject var viewModel: AddAnswerViewModel
    @FocusState private var isFieldFocused: Bool
    
    let colors: [Color] = [.white, .black, .red, .yellow, .green, .blue, .purple]
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.75)
            
            TextField(
                "",
                text: $viewModel.tempTextObject.text,
                prompt:
                    Text("텍스트를 입력하세요.")
                    .foregroundColor(viewModel.tempTextObject.textColor),
                axis: .vertical
            )
            .font(
                .custom("SUIT", size: viewModel.tempTextObject.fontSize)
            )
            .foregroundColor(viewModel.tempTextObject.textColor)
            .fontWeight(
                viewModel.tempTextObject.isBold ? .bold : .regular
            )
            .lineLimit(nil)
            .padding(.leading, 24)
            .focused($isFieldFocused)
            .autocorrectionDisabled()
            .onSubmit {
                viewModel.tempTextObject.text += "\n"
                isFieldFocused = true
            }
            
            HStack {
                Text("취소")
                    .label2(font: "SUIT", color: .cheekBackgroundTeritory, bold: true)
                    .onTapGesture {
                        viewModel.cancelTextView()
                    }
                
                Spacer()
                
                Text("완료")
                    .label2(font: "SUIT", color: .cheekBackgroundTeritory, bold: true)
                    .onTapGesture {
                        viewModel.editTextObject = false
                        
                        viewModel.stackItems[viewModel.currentIndex] = viewModel.tempTextObject
                        viewModel.canvas.becomeFirstResponder()
                    }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .frame(maxHeight: .infinity, alignment: .top)
            
            TextPaletteView(viewModel: viewModel)
                .frame(maxHeight: .infinity, alignment: .bottom)
        }
    }
}

#Preview {
    AddAnswerView()
}
