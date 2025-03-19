//
//  ColorThemeExampleView.swift
//  SupaSet
//
//  Created by Rishi Garg on 3/18/25.
//


import SwiftUI
extension UIColor {
    /// Returns the HSL components (Hue, Saturation, Lightness, Alpha) for the UIColor.
    var hsl: (h: CGFloat, s: CGFloat, l: CGFloat, a: CGFloat) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        let maxVal = max(r, g, b)
        let minVal = min(r, g, b)
        let l = (maxVal + minVal) / 2
        
        var h: CGFloat = 0
        var s: CGFloat = 0
        
        let delta = maxVal - minVal
        if delta != 0 {
            s = l > 0.5 ? delta / (2 - maxVal - minVal) : delta / (maxVal + minVal)
            
            if maxVal == r {
                h = (g - b) / delta + (g < b ? 6 : 0)
            } else if maxVal == g {
                h = (b - r) / delta + 2
            } else { // maxVal == b
                h = (r - g) / delta + 4
            }
            h /= 6
        }
        return (h, s, l, a)
    }
    
    /// Creates a UIColor from HSL components.
    static func colorFromHSL(h: CGFloat, s: CGFloat, l: CGFloat, a: CGFloat) -> UIColor {
        func hue2rgb(p: CGFloat, q: CGFloat, t: CGFloat) -> CGFloat {
            var t = t
            if t < 0 { t += 1 }
            if t > 1 { t -= 1 }
            if t < 1/6 { return p + (q - p) * 6 * t }
            if t < 1/2 { return q }
            if t < 2/3 { return p + (q - p) * (2/3 - t) * 6 }
            return p
        }
        
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        
        if s == 0 {
            r = l; g = l; b = l
        } else {
            let q = l < 0.5 ? l * (1 + s) : l + s - l * s
            let p = 2 * l - q
            r = hue2rgb(p: p, q: q, t: h + 1/3)
            g = hue2rgb(p: p, q: q, t: h)
            b = hue2rgb(p: p, q: q, t: h - 1/3)
        }
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}


// MARK: - Color Theme Extension
extension Color {
    // MARK: - Base Colors
    static let themePrimary = Color("PrimaryThemeColor")            // #14110F
    static let themePrimarySecond = Color("PrimaryThemeColorTwo") // #34312D
    static let themeSecondary = Color("SecondaryThemeColor")        // #6493B3
    static let themeAccent = Color("AccentColor")              // #0B2445
    
    // MARK: - Shade/Tint Generation
    
    /// Adjusts the color by the given percentage
    /// - Parameter percentage: The percentage to adjust by (-100 to 100)
    ///   * Positive: Creates tints (lightens the color)
    ///   * Negative: Creates shades (darkens the color)
    ///   * 0: Returns the original color
    /// - Returns: A new color that is a tint or shade of the original
    func adjusted(by percentage: Double) -> Color {
        // Clamp percentage to -100...100.
        let clamped = min(max(percentage, -100), 100)
        let uiColor = UIColor(self)
        let (h, s, l, a) = uiColor.hsl
        
        // For tints, we increase the lightness toward 1.
        // For shades, we decrease the lightness toward 0.
        let newL: CGFloat
        if clamped > 0 {
            newL = l + (1 - l) * CGFloat(clamped / 100)
        } else if clamped < 0 {
            newL = l * (1 + CGFloat(clamped / 100))
        } else {
            newL = l
        }
        
        let adjustedUIColor = UIColor.colorFromHSL(h: h, s: s, l: newL, a: a)
        return Color(adjustedUIColor)
    }
    
    /// Returns a tint of the current color (lighter)
    /// - Parameter percentage: The percentage to lighten (0-100)
    /// - Returns: A lightened color
    func tint(_ percentage: Double) -> Color {
        return adjusted(by: abs(percentage))
    }
    
    /// Returns a shade of the current color (darker)
    /// - Parameter percentage: The percentage to darken (0-100)
    /// - Returns: A darkened color
    func shade(_ percentage: Double) -> Color {
        return adjusted(by: -abs(percentage))
    }
    
    // MARK: - Theme Color Convenience Methods
    
    /// Returns either black or white color that provides the best contrast against this color
    /// Uses the W3C recommended contrast calculation algorithm
    func bestTextColor() -> Color {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        
        // Convert to UIColor to access RGB components
        guard UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            // Default to white if conversion fails
            return .white
        }
        
        // Apply gamma correction for luminance perception
        let gammaRed = red <= 0.03928 ? red / 12.92 : pow((red + 0.055) / 1.055, 2.4)
        let gammaGreen = green <= 0.03928 ? green / 12.92 : pow((green + 0.055) / 1.055, 2.4)
        let gammaBlue = blue <= 0.03928 ? blue / 12.92 : pow((blue + 0.055) / 1.055, 2.4)
        
        // Calculate luminance using W3C recommendation for perceived brightness
        // L = 0.2126 * R + 0.7152 * G + 0.0722 * B
        let luminance = 0.2126 * gammaRed + 0.7152 * gammaGreen + 0.0722 * gammaBlue
        
        // Return white for dark backgrounds, black for light backgrounds
        // The threshold of 0.5 is a common standard for this decision
        return luminance > 0.2 ? .black : .white
    }
    
    /// Same as bestTextColor but returned as a UIColor
    func bestTextColorUIColor() -> UIColor {
        let color = self.bestTextColor()
        return UIColor(color)
    }
    /// Get a tint or shade of the primary theme color
    /// - Parameter percentage: Percentage (-100 to 100), positive for tints, negative for shades
    /// - Returns: A tinted/shaded version of the primary color
    static func primaryAdjusted(by percentage: Double) -> Color {
        return Color.themePrimary.adjusted(by: percentage)
    }
    
    /// Get a tint or shade of the primarySecond theme color
    /// - Parameter percentage: Percentage (-100 to 100), positive for tints, negative for shades
    /// - Returns: A tinted/shaded version of the primarySecond color
    static func primarySecondAdjusted(by percentage: Double) -> Color {
        return Color.themePrimarySecond.adjusted(by: percentage)
    }
    
    /// Get a tint or shade of the secondary theme color
    /// - Parameter percentage: Percentage (-100 to 100), positive for tints, negative for shades
    /// - Returns: A tinted/shaded version of the secondary color
    static func secondaryAdjusted(by percentage: Double) -> Color {
        return Color.themeSecondary.adjusted(by: percentage)
    }
    
    /// Get a tint or shade of the accent theme color
    /// - Parameter percentage: Percentage (-100 to 100), positive for tints, negative for shades
    /// - Returns: A tinted/shaded version of the accent color
    static func accentAdjusted(by percentage: Double) -> Color {
        return Color.themeAccent.adjusted(by: percentage)
    }
    
}

// MARK: - Color Hex Initializer
extension Color {
    /// Initialize a Color from a hex string
    /// - Parameter hex: A hex string, with or without the '#' prefix (e.g., "#FF0000" or "FF0000")
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
extension Color {
    var isDark: Bool {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0
        guard UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: nil) else {
            return false
        }
        
        let lum = 0.2126 * red + 0.7152 * green + 0.0722 * blue
        return lum < 0.5
    }
}
// MARK: - Theme Styles
extension View {
    /// Apply primary styling to a view (background and text color)
    /// - Parameter adjustPercentage: Optional percentage to adjust the background color
    /// - Returns: A styled view
    func primaryStyle(adjustPercentage: Double = 0) -> some View {
        let backgroundColor = Color.primaryAdjusted(by: adjustPercentage)
        return self
            .background(backgroundColor)
            .foregroundColor(backgroundColor.bestTextColor())
    }
    func primarySecondStyle(adjustPercentage: Double = 0) -> some View {
        let backgroundColor = Color.primarySecondAdjusted(by: adjustPercentage)
        return self
            .background(backgroundColor)
            .foregroundColor(backgroundColor.bestTextColor())
    }
    
    /// Apply secondary styling to a view (background and text color)
    /// - Parameter adjustPercentage: Optional percentage to adjust the background color
    /// - Returns: A styled view
    func secondaryStyle(adjustPercentage: Double = 0) -> some View {
        let backgroundColor = Color.secondaryAdjusted(by: adjustPercentage)
        return self
            .background(backgroundColor)
            .foregroundColor(backgroundColor.bestTextColor())
    }
    
    /// Apply accent styling to a view (background and text color)
    /// - Parameter adjustPercentage: Optional percentage to adjust the background color
    /// - Returns: A styled view
    func accentStyle(adjustPercentage: Double = 0) -> some View {
        let backgroundColor = Color.accentAdjusted(by: adjustPercentage)
        return self
            .background(backgroundColor)
            .foregroundColor(backgroundColor.bestTextColor())
    }
}

// MARK: - Example Usage
struct ColorThemeExampleView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Group {
                    // Base colors with adaptive text
                    Text("Primary")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.themePrimary)
                        .foregroundColor(Color.themePrimary.bestTextColor())
                    
                    Text("Primary Second")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.themePrimarySecond)
                        .foregroundColor(Color.themePrimarySecond.bestTextColor())
                    
                    Text("Secondary")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.themeSecondary)
                        .foregroundColor(Color.themeSecondary.bestTextColor())
                    
                    Text("Accent")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.themeAccent)
                        .foregroundColor(Color.themeAccent.bestTextColor())
                }
                
                // Color contrast examples
                Text("Color Contrast Examples")
                    .font(.headline)
                    .padding(.top)
                
                Group {
                    // Dynamic tints and shades with adaptive text
                    Text("Primary +50% (Tint)")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.primaryAdjusted(by: 50))
                        .foregroundColor(Color.primaryAdjusted(by: 50).bestTextColor())
                    
                    Text("Primary -25% (Shade)")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.primaryAdjusted(by: -25))
                        .foregroundColor(Color.primaryAdjusted(by: -25).bestTextColor())
                    
                    Text("Secondary +75% (Tint)")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.secondaryAdjusted(by: 75))
                        .foregroundColor(Color.secondaryAdjusted(by: 75).bestTextColor())
                    
                    Text("Accent -50% (Shade)")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.accentAdjusted(by: -50))
                        .foregroundColor(Color.accentAdjusted(by: -50).bestTextColor())
                }
                
                // Recommended text color examples
                Text("Recommended Theme Text Colors")
                    .font(.headline)
                    .padding(.top)
                
                Group {
                    // Using recommended text colors from palette
                    Text("Primary with recommended text")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.themePrimary)
                        .foregroundColor(Color.themePrimary.bestTextColor())
                    
                    Text("Secondary with recommended text")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.themeSecondary)
                        .foregroundColor(Color.themeSecondary.bestTextColor())
                    
                    Text("Primary +50% with recommended text")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.primaryAdjusted(by: 50))
                        .foregroundColor(Color.primaryAdjusted(by: 50).bestTextColor())
                    
                    Text("Secondary +25% with recommended text")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.secondaryAdjusted(by: 25))
                        .foregroundColor(Color.secondaryAdjusted(by: 25).bestTextColor())
                }
                
                // Style modifiers examples
                Text("Style Modifiers")
                    .font(.headline)
                    .padding(.top)
                
                Group {
                    // Using the style modifiers
                    Text("Primary Style (Default)")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .primaryStyle()
                    
                    
                    Text("Primary Style (+25% Tint)")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .primaryStyle(adjustPercentage: 25)
                    Text("Primary Style (+62.5% Tint)")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .primaryStyle(adjustPercentage: 62.5)
                    
                    Text("Secondary Style (Default)")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .secondaryStyle()
                    
                    Text("Secondary Style (-25% Shade)")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .secondaryStyle(adjustPercentage: -25)
                    
                    Text("Accent Style (Default)")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .accentStyle()
                }
                
                // Contrast demo
                Text("Contrast Test Grid")
                    .font(.headline)
                    .padding(.top)
                HStack(spacing: 1) {
                    VStack(spacing: 1) {
                        Text("%")
                            .font(.caption)
                            .frame(width: 50, height: 30)
                            .background(Color.gray.opacity(0.2))
                        ForEach([100, 87.5, 75, 62.5, 50, 37.5, 25, 12.5, 0, -12.5, -25, -37.5, -50, -62.5, -75, -87.5, -100], id: \.self) { adjustment in
                            Text("\(adjustment, specifier: "%.1f")%")
                                .font(.caption)
                                .frame(width: 50, height: 30)
                                .background(Color.gray.opacity(0.2))
                        }
                    }
                    
                    ForEach([
                        ("Primary", Color.themePrimary),
                        ("PriSec", Color.themePrimarySecond),
                        ("Secondary", Color.themeSecondary),
                        ("Accent", Color.themeAccent)
                    ], id: \.0) { name, baseColor in
                        VStack(spacing: 1) {
                            Text(name)
                                .font(.caption)
                                .frame(width: 70, height: 30)
                                .background(Color.gray.opacity(0.2))
                            
                            ForEach([100, 87.5, 75, 62.5, 50, 37.5, 25, 12.5, 0, -12.5, -25, -37.5, -50, -62.5, -75, -87.5, -100], id: \.self) { adjustment in
                                let color = baseColor.adjusted(by: Double(adjustment))
                                Text("Aa")
                                    .frame(width: 50, height: 30)
                                    .background(color)
                                    .foregroundColor(color.bestTextColor())
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
}
#Preview {
    ColorThemeExampleView()
}
