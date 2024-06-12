import SwiftUI

// 헤드라인1
struct Headline1: ViewModifier {
    var font: String
    var color: Color
    var bold: Bool
    
    func body(content: Content) -> some View {
        let uiFont = UIFont(name: font, size: 24) ?? UIFont.systemFont(ofSize: 24)
        let lineSpacing = 32 - uiFont.lineHeight
        
        return content
            .font(.custom(font, size: 24))
            .foregroundColor(color)
            .fontWeight(bold ? .bold : .regular)
            .lineSpacing(lineSpacing)
            .tracking(-0.02) // -2%
    }
}

// 제목1
struct Title1: ViewModifier {
    var font: String
    var color: Color
    var bold: Bool
    
    func body(content: Content) -> some View {
        let uiFont = UIFont(name: font, size: 20) ?? UIFont.systemFont(ofSize: 20)
        let lineSpacing = 28 - uiFont.lineHeight
        
        return content
            .font(.custom(font, size: 20))
            .foregroundColor(color)
            .fontWeight(bold ? .semibold : .regular)
            .lineSpacing(lineSpacing)
            .tracking(-0.015) // -1.5%
    }
}

// 내용1
struct Body1: ViewModifier {
    var font: String
    var color: Color
    var bold: Bool
    
    func body(content: Content) -> some View {
        let uiFont = UIFont(name: font, size: 16) ?? UIFont.systemFont(ofSize: 16)
        let lineSpacing = 24 - uiFont.lineHeight
        
        return content
            .font(.custom(font, size: 16))
            .foregroundColor(color)
            .fontWeight(bold ? .semibold : .regular)
            .lineSpacing(lineSpacing)
            .tracking(0) // 0%
    }
}

// 내용2
struct Body2: ViewModifier {
    var font: String
    var color: Color
    var bold: Bool
    
    func body(content: Content) -> some View {
        let uiFont = UIFont(name: font, size: 15) ?? UIFont.systemFont(ofSize: 15)
        let lineSpacing = 22 - uiFont.lineHeight
        
        return content
            .font(.custom(font, size: 15))
            .foregroundColor(color)
            .fontWeight(bold ? .semibold : .regular)
            .lineSpacing(lineSpacing)
            .tracking(0.005) // 0.5%
    }
}

// 라벨1
struct Label1: ViewModifier {
    var font: String
    var color: Color
    var bold: Bool
    
    func body(content: Content) -> some View {
        let uiFont = UIFont(name: font, size: 16) ?? UIFont.systemFont(ofSize: 16)
        let lineSpacing = 24 - uiFont.lineHeight
        
        return content
            .font(.custom(font, size: 16))
            .foregroundColor(color)
            .fontWeight(bold ? .semibold : .regular)
            .lineSpacing(lineSpacing)
            .tracking(0) // 0%
    }
}

// 라벨2
struct Label2: ViewModifier {
    var font: String
    var color: Color
    var bold: Bool
    
    func body(content: Content) -> some View {
        let uiFont = UIFont(name: font, size: 14) ?? UIFont.systemFont(ofSize: 14)
        let lineSpacing = 20 - uiFont.lineHeight
        
        return content
            .font(.custom(font, size: 14))
            .foregroundColor(color)
            .fontWeight(bold ? .semibold : .regular)
            .lineSpacing(lineSpacing)
            .tracking(0.005) // 0.5%
    }
}

// 설명1
struct Caption1: ViewModifier {
    var font: String
    var color: Color
    var bold: Bool
    
    func body(content: Content) -> some View {
        let uiFont = UIFont(name: font, size: 12) ?? UIFont.systemFont(ofSize: 12)
        let lineSpacing = 16 - uiFont.lineHeight
        
        return content
            .font(.custom(font, size: 12))
            .foregroundColor(color)
            .fontWeight(bold ? .semibold : .regular)
            .lineSpacing(lineSpacing)
            .tracking(0.01) // 1%
    }
}

extension View {
    // 헤드라인1
    func headline1(font: String, color: Color, bold: Bool) -> some View {
        self.modifier(Headline1(font: font, color: color, bold: bold))
    }
    
    // 제목1
    func title1(font: String, color: Color, bold: Bool) -> some View {
        self.modifier(Title1(font: font, color: color, bold: bold))
    }
    
    // 내용1
    func body1(font: String, color: Color, bold: Bool) -> some View {
        self.modifier(Body1(font: font, color: color, bold: bold))
    }
    
    // 내용2
    func body2(font: String, color: Color, bold: Bool) -> some View {
        self.modifier(Body2(font: font, color: color, bold: bold))
    }
    
    // 라벨1
    func label1(font: String, color: Color, bold: Bool) -> some View {
        self.modifier(Label1(font: font, color: color, bold: bold))
    }
    
    // 라벨2
    func label2(font: String, color: Color, bold: Bool) -> some View {
        self.modifier(Label2(font: font, color: color, bold: bold))
    }
    
    // 설명1
    func caption1(font: String, color: Color, bold: Bool) -> some View {
        self.modifier(Caption1(font: font, color: color, bold: bold))
    }
}
