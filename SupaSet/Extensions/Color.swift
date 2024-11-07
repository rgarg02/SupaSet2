//
//  Color.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/6/24.
//

import SwiftUI
///https://www.realtimecolors.com/?colors=f7f1ed-0b0704-d2b593-677a33-bd7328&fonts=Albert%20Sans-Albert%20Sans
struct Theme {
    // MARK: - Main Colors
    let accent = Color("AccentColor")
    let background = Color("BackgroundColor")
    let text = Color("TextColor")
    let primary = Color("PrimaryThemeColor")
    let secondary = Color("SecondaryThemeColor")
    let secondaryLight = Color("SecondaryColorLight")
}

// MARK: - Color Extension
extension Color {
    static let theme = Theme()
}
extension Color {
    func lighter() -> Color {
        // Convert main color to lighter tint
        let uiColor = UIColor(self)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        
        // Create lighter version by reducing saturation and increasing brightness
        return Color(hue: Double(h),
                    saturation: Double(s) * 0.15, // Reduce saturation
                    brightness: Double(b) + ((1.0 - Double(b)) * 0.4)) // Increase brightness
    }
}
