//
//  AddStoryView.swift
//  CHEEK
//
//  Created by 김태은 on 6/13/24.
//

import SwiftUI
import PhotosUI

let paletteColors: [Color] = [
    Color(red: 0.9, green: 0.1, blue: 0.05), // 빵강
    Color(red: 1, green: 0.75, blue: 0.23), // 주황
    Color(red: 0.91, green: 0.92, blue: 0.28), // 노랑
    Color(red: 0.24, green: 0.75, blue: 0.38), // 초록
    Color(red: 0.28, green: 0.92, blue: 0.88), // 하늘
    Color(red: 0.35, green: 0.58, blue: 0.93), // 파랑
    Color(red: 0.45, green: 0.28, blue: 0.92), // 남색
    Color(red: 0.87, green: 0.28, blue: 0.92), // 보라
    Color(red: 0.92, green: 0.28, blue: 0.59) // 분홍
]

let paletteGreyscales: [Color] = [
    Color(red: 1, green: 1, blue: 1),
    Color(red: 0.96, green: 0.96, blue: 0.96),
    Color(red: 0.89, green: 0.89, blue: 0.88),
    Color(red: 0.77, green: 0.77, blue: 0.77),
    Color(red: 0.54, green: 0.54, blue: 0.54),
    Color(red: 0.25, green: 0.25, blue: 0.25),
    Color(red: 0.09, green: 0.09, blue: 0.09),
    Color(red: 0, green: 0, blue: 0)
]

struct AddAnswerView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var authViewModel: AuthenticationViewModel
    
    var questionId: Int64
    
    @StateObject var viewModel = AddAnswerViewModel()
    @State var questionModel: QuestionModel? = nil
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                LoadingView()
            } else {
                ZStack(alignment: .top) {
                    // 캔버스
                    GeometryReader { _ in
                        AnswerDrawingView(viewModel: viewModel)
                            .frame(
                                width: UIScreen.main.bounds.width,
                                height: (UIScreen.main.bounds.width / 9) * 16
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .ignoresSafeArea(.keyboard, edges: .all)
                }
                
                // 메뉴
                if viewModel.userInteractState == .save {
                    AddAnswerMenusView(viewModel: viewModel)
                        .padding(.top, 16)
                }
                
                // 텍스트
                if viewModel.userInteractState == .text {
                    // 텍스트 추가
                    if viewModel.addTextObject {
                        AddTextObjectView(viewModel: viewModel)
                    }
                    
                    // 텍스트 수정
                    if viewModel.editTextObject {
                        EditTextObjectView(viewModel: viewModel)
                    }
                }
                
                // 그리기 팔레트
                if viewModel.userInteractState == .draw {
                    DrawPaletteView(viewModel: viewModel)
                }
                
                // 배경색 팔레트
                if viewModel.userInteractState == .backgroundColor {
                    BackgroundColorPaletteView(viewModel: viewModel)
                }
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
            viewModel.getQuestion(questionId: questionId)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.cheekTextNormal)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onAppear {
            UINavigationBar.setAnimationsEnabled(false)
            AppState.shared.swipeEnabled = false
            
            authViewModel.checkRefreshTokenValid()
        }
        .onDisappear {
            UINavigationBar.setAnimationsEnabled(true)
            AppState.shared.swipeEnabled = true
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text("오류"),
                message: Text(viewModel.alertMessage),
                dismissButton: .default(
                    Text("확인"),
                    action: {
                        dismiss()
                    }
                )
            )
        }
    }
}

// 메뉴 아이콘
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
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var viewModel: AddAnswerViewModel
    
    @State private var photosPickerItem: PhotosPickerItem?
    @State private var showPhotosPicker: Bool = false
    
    var body: some View {
        VStack {
            HStack(spacing: 12) {
                // 뒤로가기
                AddAnswerMenu(image: "IconX")
                    .onTapGesture {
                        dismiss()
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
                AddAnswerMenu(image: "IconPalette")
                    .onTapGesture {
                        viewModel.userInteractState = .backgroundColor
                    }
            }
            
            Spacer()
            
            Text("스토리 추가")
                .body1(font: "SUIT", color: .cheekTextNormal, bold: true)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(.cheekLineAlternative)
                )
                .onTapGesture {
                    uploadStory()
                }
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    func uploadStory() {
        viewModel.saveCanvasImage() {
            AnswerDrawingView(viewModel: viewModel)
        } completion: { isSuccess in
            if isSuccess {
                print("스토리 업로드 성공")
            } else {
                print("스토리 업로드 실패")
            }
            
            DispatchQueue.main.async {
                dismiss()
            }
        }
    }
}

// 그리기 팔레트
struct DrawPaletteView: View {
    @ObservedObject var viewModel: AddAnswerViewModel
    
    @State private var selectedTab: Int = 0
    @State private var tabViewHeight: CGFloat = 1
    
    var body: some View {
        ZStack {
            LinearGradient(
                stops: [
                    Gradient.Stop(color: .cheekBlack.opacity(0.2), location: 0.00),
                    Gradient.Stop(color: .cheekBlack.opacity(0), location: 1.00),
                ],
                startPoint: UnitPoint(x: 0.5, y: 0),
                endPoint: UnitPoint(x: 0.5, y: 0.14)
            )
            .allowsHitTesting(false)
            
            HStack {
                Text("취소")
                    .label1(font: "SUIT", color: .cheekWhite, bold: true)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 12)
                    .onTapGesture {
                        viewModel.userInteractState = .save
                    }
                
                Spacer()
                
                HStack(spacing: 16) {
                    if viewModel.inkType == .marker {
                        Image("IconMarkerEnabled")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .foregroundColor(.cheekWhite)
                            .onTapGesture {
                                viewModel.inkType = .marker
                                viewModel.inkWidth = 20
                            }
                    } else {
                        Image("IconMarkerDisabled")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .foregroundColor(.cheekWhite)
                            .onTapGesture {
                                viewModel.inkType = .marker
                                viewModel.inkWidth = 20
                            }
                    }
                    
                    if viewModel.inkType == .pen {
                        Image("IconPenEnabled")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .foregroundColor(.cheekWhite)
                            .onTapGesture {
                                viewModel.inkType = .pen
                                viewModel.inkWidth = 5
                            }
                    } else {
                        Image("IconPenDisabled")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .foregroundColor(.cheekWhite)
                            .onTapGesture {
                                viewModel.inkType = .pen
                                viewModel.inkWidth = 5
                            }
                    }
                }
                
                Spacer()
                
                Text("확인")
                    .label1(font: "SUIT", color: .cheekWhite, bold: true)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 12)
                    .onTapGesture {
                        viewModel.userInteractState = .save
                    }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .frame(maxHeight: .infinity, alignment: .top)
            
            VStack(spacing: 10) {
                TabView(selection: $selectedTab) {
                    HStack(spacing: 14) {
                        ForEach(paletteColors, id: \.self) { color in
                            Circle()
                                .frame(width: 24, height: 24)
                                .foregroundColor(color)
                                .overlay(
                                    Circle()
                                        .strokeBorder(.cheekWhite, lineWidth: 1)
                                    
                                )
                                .onTapGesture {
                                    viewModel.isDraw = true
                                    viewModel.inkColor = color
                                }
                        }
                    }
                    .background(
                        GeometryReader { geometry in
                            Color.clear
                                .preference(key: HeightPreferenceKey.self, value: geometry.size.height)
                        }
                    )
                    .onPreferenceChange(HeightPreferenceKey.self) { value in
                        tabViewHeight = value
                    }
                    .tag(0)
                    
                    if viewModel.inkType == .pen {
                        HStack(spacing: 14) {
                            ForEach(paletteGreyscales, id: \.self) { color in
                                Circle()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(color)
                                    .overlay(
                                        Circle()
                                            .stroke(.cheekWhite, lineWidth: 1)
                                        
                                    )
                                    .onTapGesture {
                                        viewModel.isDraw = true
                                        viewModel.inkColor = color
                                    }
                            }
                        }
                        .background(
                            GeometryReader { geometry in
                                Color.clear
                                    .preference(key: HeightPreferenceKey.self, value: geometry.size.height)
                            }
                        )
                        .onPreferenceChange(HeightPreferenceKey.self) { value in
                            tabViewHeight = value
                        }
                        .tag(1)
                    }
                }
                .frame(height: tabViewHeight)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                HStack(spacing: 8) {
                    Circle()
                        .frame(width: 8, height: 8)
                        .foregroundColor(selectedTab == 0 ? .cheekTextAlternative : .cheekGrey200)
                    
                    
                    if viewModel.inkType == .pen {
                        Circle()
                            .frame(width: 8, height: 8)
                            .foregroundColor(selectedTab == 1 ? .cheekTextAlternative : .cheekGrey200)
                    }
                }
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .onChange(of: viewModel.inkType) { inkType in
                if inkType == .marker {
                    selectedTab = 0
                    viewModel.inkColor = paletteColors[0]
                }
            }
        }
    }
}

// 배경색 팔레트
struct BackgroundColorPaletteView: View {
    @ObservedObject var viewModel: AddAnswerViewModel
    
    @State private var selectedTab: Int = 0
    @State private var tabViewHeight: CGFloat = 1
    
    var body: some View {
        ZStack {
            LinearGradient(
                stops: [
                    Gradient.Stop(color: .cheekBlack.opacity(0.2), location: 0.00),
                    Gradient.Stop(color: .cheekBlack.opacity(0), location: 1.00),
                ],
                startPoint: UnitPoint(x: 0.5, y: 0),
                endPoint: UnitPoint(x: 0.5, y: 0.14)
            )
            .allowsHitTesting(false)
            
            HStack {
                Text("취소")
                    .label1(font: "SUIT", color: .cheekWhite, bold: true)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 12)
                    .onTapGesture {
                        viewModel.userInteractState = .save
                    }
                
                Spacer()
                
                Text("확인")
                    .label1(font: "SUIT", color: .cheekWhite, bold: true)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 12)
                    .onTapGesture {
                        viewModel.userInteractState = .save
                    }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .frame(maxHeight: .infinity, alignment: .top)
            
            VStack(spacing: 10) {
                TabView(selection: $selectedTab) {
                    HStack(spacing: 14) {
                        ForEach(paletteColors, id: \.self) { color in
                            Circle()
                                .frame(width: 24, height: 24)
                                .foregroundColor(color)
                                .overlay(
                                    Circle()
                                        .strokeBorder(.cheekWhite, lineWidth: 1)
                                    
                                )
                                .onTapGesture {
                                    viewModel.frameBackgroundColor = color
                                }
                        }
                    }
                    .background(
                        GeometryReader { geometry in
                            Color.clear
                                .preference(key: HeightPreferenceKey.self, value: geometry.size.height)
                        }
                    )
                    .onPreferenceChange(HeightPreferenceKey.self) { value in
                        tabViewHeight = value
                    }
                    .tag(0)
                    
                    HStack(spacing: 14) {
                        ForEach(paletteGreyscales, id: \.self) { color in
                            Circle()
                                .frame(width: 24, height: 24)
                                .foregroundColor(color)
                                .overlay(
                                    Circle()
                                        .stroke(.cheekWhite, lineWidth: 1)
                                    
                                )
                                .onTapGesture {
                                    viewModel.frameBackgroundColor = color
                                }
                        }
                    }
                    .background(
                        GeometryReader { geometry in
                            Color.clear
                                .preference(key: HeightPreferenceKey.self, value: geometry.size.height)
                        }
                    )
                    .onPreferenceChange(HeightPreferenceKey.self) { value in
                        tabViewHeight = value
                    }
                    .tag(1)
                }
                .frame(height: tabViewHeight)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                HStack(spacing: 8) {
                    Circle()
                        .frame(width: 8, height: 8)
                        .foregroundColor(selectedTab == 0 ? .cheekTextAlternative : .cheekGrey200)
                    
                    Circle()
                        .frame(width: 8, height: 8)
                        .foregroundColor(selectedTab == 1 ? .cheekTextAlternative : .cheekGrey200)
                    
                }
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
    }
}

// 텍스트 추가
struct AddTextObjectView: View {
    @ObservedObject var viewModel: AddAnswerViewModel
    @State private var frame = CGRect.zero
    @FocusState private var isFieldFocused: Bool
    
    var body: some View {
        ZStack {
            Color.cheekBlack.opacity(0.4)
            
            ZStack {
                Text(viewModel.stackItems[viewModel.currentIndex].text)
                    .body1(font: "SUIT", color: .cheekWhite, bold: true)
                    .multilineTextAlignment(.center)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundColor(.cheekBlack.opacity(0.6))
                    )
                    .background(rectReader($frame))
                
                TextField(
                    "",
                    text: $viewModel.stackItems[viewModel.currentIndex].text,
                    axis: .vertical)
                    .body1(font: "SUIT", color: .clear, bold: true)
                    .multilineTextAlignment(.center)
                    .padding(16)
                    .frame(width: max(frame.width, 20), height: max(frame.height, 40))
                    .fixedSize()
                    .focused($isFieldFocused)
                    .autocorrectionDisabled()
                    .onSubmit {
                        viewModel.stackItems[viewModel.currentIndex].text += "\n"
                        isFieldFocused = true
                    }
            }
            
            HStack {
                Text("취소")
                    .label1(font: "SUIT", color: .cheekWhite, bold: true)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 12)
                    .onTapGesture {
                        viewModel.cancelTextView()
                        viewModel.userInteractState = .save
                    }
                
                Spacer()
                
                Text("확인")
                    .label1(font: "SUIT", color: .cheekWhite, bold: true)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 12)
                    .onTapGesture {
                        viewModel.addTextObject = false
                        viewModel.canvas.becomeFirstResponder()
                        viewModel.userInteractState = .save
                    }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .frame(maxHeight: .infinity, alignment: .top)
            .onAppear {
                isFieldFocused = true
            }
        }
    }
    
    func rectReader(_ binding: Binding<CGRect>, _ space: CoordinateSpace = .global) -> some View {
        GeometryReader { (geometry) -> Color in
            let rect = geometry.frame(in: space)
            DispatchQueue.main.async {
                binding.wrappedValue = rect
            }
            return .clear
        }
    }
}

// 텍스트 수정
struct EditTextObjectView: View {
    @ObservedObject var viewModel: AddAnswerViewModel
    @State private var frame = CGRect.zero
    @FocusState private var isFieldFocused: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
            
            ZStack {
                Text(viewModel.tempTextObject.text)
                    .body1(font: "SUIT", color: .cheekWhite, bold: true)
                    .multilineTextAlignment(.center)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundColor(.cheekBlack.opacity(0.6))
                    )
                    .background(rectReader($frame))
                
                TextField(
                    "",
                    text: $viewModel.tempTextObject.text,
                    axis: .vertical)
                    .body1(font: "SUIT", color: .clear, bold: true)
                    .multilineTextAlignment(.center)
                    .padding(16)
                    .frame(width: max(frame.width, 20), height: max(frame.height, 40))
                    .fixedSize()
                    .focused($isFieldFocused)
                    .autocorrectionDisabled()
                    .onSubmit {
                        viewModel.stackItems[viewModel.currentIndex].text += "\n"
                        isFieldFocused = true
                    }
            }
            
            HStack {
                Text("취소")
                    .label1(font: "SUIT", color: .cheekBackgroundTeritory, bold: true)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 12)
                    .onTapGesture {
                        viewModel.cancelTextView()
                        viewModel.userInteractState = .save
                    }
                
                Spacer()
                
                Text("완료")
                    .label1(font: "SUIT", color: .cheekBackgroundTeritory, bold: true)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 12)
                    .onTapGesture {
                        viewModel.editTextObject = false
                        
                        viewModel.stackItems[viewModel.currentIndex] = viewModel.tempTextObject
                        viewModel.canvas.becomeFirstResponder()
                        viewModel.userInteractState = .save
                    }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .frame(maxHeight: .infinity, alignment: .top)
            .onAppear {
                isFieldFocused = true
            }
        }
    }
    
    func rectReader(_ binding: Binding<CGRect>, _ space: CoordinateSpace = .global) -> some View {
        GeometryReader { (geometry) -> Color in
            let rect = geometry.frame(in: space)
            DispatchQueue.main.async {
                binding.wrappedValue = rect
            }
            return .clear
        }
    }
}

#Preview {
    AddAnswerView(authViewModel: AuthenticationViewModel(), questionId: 1)
}
