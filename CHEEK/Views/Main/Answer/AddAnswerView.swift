//
//  AddStoryView.swift
//  CHEEK
//
//  Created by 김태은 on 6/13/24.
//

import SwiftUI
import PhotosUI

struct AddAnswerView: View {
    @StateObject var viewModel = AddAnswerViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                ZStack(alignment: .top) {
                    // 캔버스
                    AnswerDrawingView(viewModel: viewModel)
                        .aspectRatio(9 / 16, contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .clipShape(Rectangle())
                    
                    
                    // 메뉴
                    AddAnswerMenusView(viewModel: viewModel)
                        .frame(maxHeight: .infinity, alignment: .top)
                        .offset(y: 16)
                }
                
                
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
            .onAppear {
                // 질문 오브젝트 추가
                viewModel.stackItems.append(
                    AnswerStackModel(
                        type: "question",
                        view:
                            AnyView(
                                AnswerQuestionBlock()
                            )
                    )
                )
            }
            .background(.cheekTextNormal)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
}

struct AddAnswerMenu: View {
    var image: String
    
    var body: some View {
        Image(image)
            .resizable()
            .frame(width: 32, height: 32)
            .foregroundColor(.cheekWhite)
            .padding(8)
            .background(
                Circle()
                    .foregroundColor(Color(red: 0.29, green: 0.29, blue: 0.29).opacity(0.6))
            )
    }
}

// 메뉴
struct AddAnswerMenusView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var viewModel: AddAnswerViewModel
    @State private var photosPickerItem: PhotosPickerItem?
    @State private var showPhotosPicker: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            // 뒤로가기
            AddAnswerMenu(image: "IconX")
                .onTapGesture {
                    presentationMode.wrappedValue.dismiss()
                }
            
            Spacer()
            
            // 텍스트
            AddAnswerMenu(image: "IconFont")
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
            AddAnswerMenu(image: "IconDraw")
                .onTapGesture {
                    viewModel.userInteractState = .draw
                }
            
            // 사진
            AddAnswerMenu(image: "IconPic")
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
            AddAnswerMenu(image: "IconColor")
                .onTapGesture {
                    viewModel.userInteractState = .backgroundColor
                }
            
            // 저장(임시)
            EmptyView()
                .onTapGesture {
                    viewModel.userInteractState = .save
                    
                    viewModel.saveCanvasImage() {
                        AnswerDrawingView(viewModel: viewModel)
                    }
                }
        }
        .padding(.horizontal, 16)
    }
}


// 질문 View
struct AnswerQuestionBlock: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                ProfileXS(url: "")
                
                Text("최대8자의닉네임")
                    .body2(font: "SUIT", color: .cheekTextStrong, bold: true)
                
                Spacer()
            }
            
            Text("test")
                .label2(font: "SUIT", color: .cheekTextStrong, bold: false)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: 207)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .foregroundColor(.cheekWhite)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.cheekTextAlternative, lineWidth: 1)
                )
            
        )
    }
}

// 텍스트 팔레트
struct TextPaletteView: View {
    @ObservedObject var viewModel: AddAnswerViewModel
    let colors: [Color] = [.white, .black, .red, .yellow, .green, .blue, .purple]
    
    var body: some View {
        VStack(spacing: 10) {
            Slider(value: viewModel.editTextObject ? $viewModel.tempTextObject.fontSize : $viewModel.stackItems[viewModel.currentIndex].fontSize, in: 15...30, step: 0.1)
                .frame(width: (20 * CGFloat(colors.count)) + (10 * (CGFloat(colors.count) - 1)))
            
            HStack(spacing: 10) {
                ForEach(colors, id: \.self) { color in
                    Circle()
                        .frame(width: 20, height: 20)
                        .foregroundColor(color)
                        .onTapGesture {
                            if viewModel.editTextObject {
                                viewModel.tempTextObject.textColor = color
                            } else {
                                viewModel.stackItems[viewModel.currentIndex].textColor = color
                            }
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
