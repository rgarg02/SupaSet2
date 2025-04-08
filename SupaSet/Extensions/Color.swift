//
//  Color.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/6/24.
//

import SwiftUI
///https://www.realtimecolors.com/?colors=000000-ffffff-7c4d18-86b011-cf852a&fonts=Albert%20Sans-Albert%20Sans
struct Theme : Hashable{
    // MARK: - Main Colors
    let accent = Color("AccentColor")
    let background = Color("BackgroundColor")
    let text = Color("TextColor")
    let primary = Color("PrimaryThemeColor")
    let secondary = Color("SecondaryThemeColor")
    let secondarySecond = Color("SecondaryThemeColorTwo")
    let primarySecond = Color("PrimaryThemeColorTwo")
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
extension Color {
    
    /// Returns a lighter or darker shade of the color.
    /// - Parameter percentage: The percentage to adjust the brightness (-100 to 100).
    /// - Returns: A new `Color` with the adjusted brightness.
    func shade(by percentage: Double) -> Color {
        let uiColor = UIColor(self)
        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0

        if uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            let adjustedBrightness = max(min(brightness + CGFloat(percentage) / 100, 1.0), 0.0)
            return Color(UIColor(hue: hue, saturation: saturation, brightness: adjustedBrightness, alpha: alpha))
        }
        
        return self
    }
}
