//
//  Buttons.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/6/24.
//
import Foundation
import SwiftUI
// Custom View Modifier
struct LongButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.theme.accent) // Background color
            .cornerRadius(25) // Medium size dimension divided by 2
            .frame(height: 50) // Medium size dimension
    }
}
struct CustomButtonStyle {
    enum Size {
        case small, medium, large
        
        var dimension: CGFloat {
            switch self {
            case .small: return 40
            case .medium: return 50
            case .large: return 60
            }
        }
        
        var iconSize: Font {
            switch self {
            case .small: return .body
            case .medium: return .title3
            case .large: return .title2
            }
        }
    }
    
    enum Style {
        case filled(background: Color? = nil, foreground: Color? = nil)
        case outlined(foreground: Color? = nil, border: Color? = nil)
        case ghost(foreground: Color? = nil)
        
        var backgroundColor: Color {
            switch self {
            case .filled(let background, _):
                return background ?? .theme.primary
            case .outlined, .ghost:
                return .clear
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .filled(_, let foreground):
                return foreground ?? .theme.background
            case .outlined(let foreground, _):
                return foreground ?? .theme.text
            case .ghost(let foreground):
                return foreground ?? .theme.text
            }
        }
        
        var borderColor: Color {
            switch self {
            case .outlined(_, let border):
                return border ?? .theme.text
            case .filled, .ghost:
                return .clear
            }
        }
    }
}

// MARK: - Custom Button View
struct CustomButton: View {
    let icon: String?
    let title: String?
    let size: CustomButtonStyle.Size
    let style: CustomButtonStyle.Style
    let action: () -> Void
    
    var namespace: Namespace.ID?
    var matchGeometry: Bool
    
    init(
        icon: String? = nil,
        title: String? = nil,
        size: CustomButtonStyle.Size = .medium,
        style: CustomButtonStyle.Style = .filled(),
        matchGeometry: Bool = false,
        namespace: Namespace.ID? = nil,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.size = size
        self.style = style
        self.action = action
        self.matchGeometry = matchGeometry
        self.namespace = namespace
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                if matchGeometry {
                    style.backgroundColor
                        .matchedGeometryEffect(id: "background", in: namespace!)
                } else {
                    style.backgroundColor
                }
                
                HStack(spacing: 8) {
                    if let icon = icon {
                        if matchGeometry {
                            Image(systemName: icon)
                                .font(size.iconSize)
                                .matchedGeometryEffect(id: "icon", in: namespace!)
                        } else {
                            Image(systemName: icon)
                                .font(size.iconSize)
                        }
                    }
                    
                    if let title = title {
                        Text(title)
                            .font(.headline)
                    }
                }
                .foregroundColor(style.foregroundColor)
            }
        }
        .frame(
            width: title == nil ? size.dimension : nil,
            height: size.dimension
        )
        .cornerRadius(size.dimension / 2)
        .overlay(
            RoundedRectangle(cornerRadius: size.dimension / 2)
                .stroke(style.borderColor, lineWidth: 2)
        )
    }
}

// MARK: - Preview Provider
#Preview("Button Styles"){
    ScrollView {
        VStack(spacing: 20) {
            Group {
                // Default theme buttons
                CustomButton(
                    icon: "plus",
                    title: "Default Filled",
                    style: .filled(),
                    action: {}
                )
                
                CustomButton(
                    icon: "star",
                    title: "Default Outlined",
                    style: .outlined(),
                    action: {}
                )
                
                CustomButton(
                    icon: "heart",
                    title: "Default Ghost",
                    style: .ghost(),
                    action: {}
                )
            }
            
            Group {
                // Custom colored buttons
                CustomButton(
                    icon: "plus",
                    title: "Custom Filled",
                    style: .filled(
                        background: .theme.accent,
                        foreground: .theme.background
                    ),
                    action: {}
                )
                CustomButton(
                    icon: "star",
                    title: "Custom Outlined",
                    style: .outlined(
                        foreground: .theme.accent,
                        border: .theme.accent
                    ),
                    action: {}
                )
                
                CustomButton(
                    icon: "heart",
                    title: "Custom Ghost",
                    style: .ghost(foreground: .theme.accent),
                    action: {}
                )
            }
            
            Group {
                // Size variations
                HStack {
                    CustomButton(
                        icon: "plus",
                        size: .small,
                        style: .filled(background: .theme.accent),
                        action: {}
                    )
                    
                    CustomButton(
                        icon: "plus",
                        size: .medium,
                        style: .filled(background: .theme.accent),
                        action: {}
                    )
                    
                    CustomButton(
                        icon: "plus",
                        size: .large,
                        style: .filled(background: .theme.accent),
                        action: {}
                    )
                }
            }
        }
        .padding()
    }
}
#Preview("More Button Styles") {
    VStack(spacing: 20) {
        // Default theme buttons
        CustomButton(
            icon: "plus",
            title: "Add Item",
            style: .filled(),
            action: {}
        )

        // Custom colored filled button
        CustomButton(
            icon: "star",
            title: "Favorite",
            style: .filled(
                background: .theme.accent,
                foreground: .theme.background
            ),
            action: {}
        )

        // Custom outlined button
        CustomButton(
            icon: "heart",
            title: "Like",
            style: .outlined(
                foreground: .red,
                border: .red
            ),
            action: {}
        )

        // Custom ghost button
        CustomButton(
            icon: "trash",
            title: "Delete",
            style: .ghost(foreground: .red),
            action: {}
        )

        // Icon-only button
        CustomButton(
            icon: "plus",
            size: .small,
            style: .filled(background: .theme.accent),
            action: {}
        )
    }
    .padding()
}
