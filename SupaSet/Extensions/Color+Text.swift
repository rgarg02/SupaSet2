//
//  Color+Text.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/7/24.
//

import SwiftUI
extension Text {
    enum TextStyle {
        case title
        case headline
        case subheadline
        case body
        case bodySecondary
        case caption
        case captionSecondary
        
        var font: Font {
            switch self {
            case .title:
                return .title.bold()
            case .headline:
                return .headline
            case .subheadline:
                return .subheadline
            case .body, .bodySecondary:
                return .body
            case .caption, .captionSecondary:
                return .caption
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .title, .headline, .body:
                return .theme.text
            case .subheadline, .bodySecondary:
                return .theme.text.opacity(0.7)
            case .caption, .captionSecondary:
                return .theme.text.opacity(0.5)
            }
        }
    }
    
    func style(_ textStyle: TextStyle) -> some View {
        self
            .font(textStyle.font)
            .foregroundColor(textStyle.foregroundColor)
    }
}
