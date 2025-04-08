//
//  Palette.swift
//  SupaSet
//
//  Created by Rishi Garg on 4/2/25.
//


import SwiftUI

// MARK: - Color Hex Helper
// MARK: - Palette Definition

struct Palette {
    let name: String
    let background: Color
    let surface: Color
    let textPrimary: Color
    let textSecondary: Color
    let accent: Color
    let success: Color
    let warning: Color
    let error: Color

    // Define static palettes here
    
    // Palette 1: Focused Energy (Blue Accent)
    static let focusedEnergyLight = Palette(
        name: "Focused Energy (Light)",
        background: Color(hex: "#FFFFFF"),
        surface: Color(hex: "#F5F5F5"),
        textPrimary: Color(hex: "#212121"),
        textSecondary: Color(hex: "#757575"),
        accent: Color(hex: "#007AFF"),
        success: Color(hex: "#34C759"),
        warning: Color(hex: "#FF9500"),
        error: Color(hex: "#FF3B30")
    )
    static let focusedEnergyDark = Palette(
        name: "Focused Energy (Dark)",
        background: Color(hex: "#121212"),
        surface: Color(hex: "#1E1E1E"),
        textPrimary: Color(hex: "#E0E0E0"),
        textSecondary: Color(hex: "#9E9E9E"),
        accent: Color(hex: "#0A84FF"),
        success: Color(hex: "#30D158"),
        warning: Color(hex: "#FF9F0A"),
        error: Color(hex: "#FF453A")
    )

    // Palette 2: Warm Power (Orange/Amber Accent)
    static let warmPowerLight = Palette(
        name: "Warm Power (Light)",
        background: Color(hex: "#F8F8F8"),
        surface: Color(hex: "#FFFFFF"),
        textPrimary: Color(hex: "#333333"),
        textSecondary: Color(hex: "#808080"),
        accent: Color(hex: "#FF8C00"), // Dark Orange for light bg
        success: Color(hex: "#28A745"),
        warning: Color(hex: "#FFC107"),
        error: Color(hex: "#DC3545")
    )
    static let warmPowerDark = Palette(
        name: "Warm Power (Dark)",
        background: Color(hex: "#1C1C1E"),
        surface: Color(hex: "#2C2C2E"),
        textPrimary: Color(hex: "#F2F2F2"),
        textSecondary: Color(hex: "#8E8E93"),
        accent: Color(hex: "#FF9F0A"), // Bright Orange for dark bg
        success: Color(hex: "#30D158"),
        warning: Color(hex: "#FFD60A"),
        error: Color(hex: "#FF453A")
    )

    // Palette 3: Fresh Growth (Teal/Green Accent)
    static let freshGrowthLight = Palette(
        name: "Fresh Growth (Light)",
        background: Color(hex: "#FAF9F6"),
        surface: Color(hex: "#FFFFFF"),
        textPrimary: Color(hex: "#3A4F4F"),
        textSecondary: Color(hex: "#708080"),
        accent: Color(hex: "#1ABC9C"),
        success: Color(hex: "#2ECC71"),
        warning: Color(hex: "#F39C12"),
        error: Color(hex: "#E74C3C")
    )
    static let freshGrowthDark = Palette(
        name: "Fresh Growth (Dark)",
        background: Color(hex: "#0F1717"),
        surface: Color(hex: "#1A2424"),
        textPrimary: Color(hex: "#E0ECEC"),
        textSecondary: Color(hex: "#90A0A0"),
        accent: Color(hex: "#30D6B0"), // Lighter Teal for dark
        success: Color(hex: "#58D68D"),
        warning: Color(hex: "#F5B041"),
        error: Color(hex: "#EC7063")
    )

    // Palette 4: Minimalist Punch (Grayscale + Vivid Accent)
    static let minimalistPunchLight = Palette(
        name: "Minimalist Punch (Light)",
        background: Color(hex: "#FFFFFF"),
        surface: Color(hex: "#F0F0F0"),
        textPrimary: Color(hex: "#000000"),
        textSecondary: Color(hex: "#666666"),
        accent: Color(hex: "#E8006F"), // Magenta
        success: Color(hex: "#4CAF50"),
        warning: Color(hex: "#FFC107"),
        error: Color(hex: "#F44336")
    )
    static let minimalistPunchDark = Palette(
        name: "Minimalist Punch (Dark)",
        background: Color(hex: "#000000"),
        surface: Color(hex: "#1A1A1A"),
        textPrimary: Color(hex: "#FFFFFF"),
        textSecondary: Color(hex: "#999999"),
        accent: Color(hex: "#FF2D8A"), // Brighter Pink/Magenta
        success: Color(hex: "#4CAF50"),
        warning: Color(hex: "#FFC107"),
        error: Color(hex: "#F44336")
    )
    
    // Add alternative Minimalist Punch with Lime if desired
     static let minimalistPunchLimeLight = Palette(
         name: "Minimalist Punch Lime (Light)",
         background: Color(hex: "#FFFFFF"),
         surface: Color(hex: "#F0F0F0"),
         textPrimary: Color(hex: "#000000"),
         textSecondary: Color(hex: "#666666"),
         accent: Color(hex: "#A3D70A"), // Adjusted Lime for better visibility on white
         success: Color(hex: "#4CAF50"),
         warning: Color(hex: "#FFC107"),
         error: Color(hex: "#F44336")
     )
     static let minimalistPunchLimeDark = Palette(
         name: "Minimalist Punch Lime (Dark)",
         background: Color(hex: "#000000"),
         surface: Color(hex: "#1A1A1A"),
         textPrimary: Color(hex: "#FFFFFF"),
         textSecondary: Color(hex: "#999999"),
         accent: Color(hex: "#DFFF00"), // Original Lime
         success: Color(hex: "#4CAF50"),
         warning: Color(hex: "#FFC107"),
         error: Color(hex: "#F44336")
     )
}

// MARK: - Sample View Using Palette

struct PaletteSampleView: View {
    let palette: Palette
    // Use environment color scheme to pick the right variant if needed,
    // but here we pass the specific light/dark palette directly.
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(palette.name)
                .font(.headline)
                .foregroundStyle(palette.textPrimary)
                .padding(.bottom, 5)

            // Card Element
            VStack(alignment: .leading) {
                Text("This is a card")
                    .font(.subheadline)
                    .foregroundStyle(palette.textPrimary)
                Text("Secondary text on surface")
                    .font(.caption)
                    .foregroundStyle(palette.textSecondary)
                HStack {
                   Text("Icon:")
                       .foregroundStyle(palette.textSecondary)
                   Image(systemName: "figure.run.circle.fill")
                       .foregroundStyle(palette.accent)
                       .imageScale(.large)
                }
            }
            .padding()
            .background(palette.surface)
            .cornerRadius(8)
            .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2) // Subtle shadow

            // Text examples
            Text("Primary Text Example")
                .font(.body)
                .foregroundStyle(palette.textPrimary)
            
            Text("Secondary Text Example")
                .font(.body)
                .foregroundStyle(palette.textSecondary)

            // Button
            Button("Accent Button") { }
                .buttonStyle(.borderedProminent)
                .tint(palette.accent) // Use tint for prominent bordered style

             // Alternative Button Style (Filled)
             Button("Filled Button") { }
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(palette.accent)
                .foregroundStyle(palette.background) // Assume accent contrasts with background
                .clipShape(Capsule())


            // Progress View
            ProgressView(value: 0.75)
                .progressViewStyle(LinearProgressViewStyle())
                .tint(palette.accent)

            // Status Indicators
            HStack(spacing: 10) {
                Label("Success", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(palette.success)
                    .font(.caption)
                Label("Warning", systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(palette.warning)
                    .font(.caption)
                Label("Error", systemImage: "xmark.octagon.fill")
                    .foregroundStyle(palette.error)
                    .font(.caption)
            }
        }
        .padding()
        .frame(maxWidth: .infinity) // Ensure VStack takes width
        .background(palette.background) // Set overall background
    }
}

// MARK: - Preview Provider

#Preview("Color Palettes") {
    // ScrollView to fit multiple palettes if needed
    ScrollView {
        VStack(spacing: 0) { // No spacing between previews
            PaletteSampleView(palette: .focusedEnergyLight)
            PaletteSampleView(palette: .focusedEnergyDark)
            Divider()
            PaletteSampleView(palette: .warmPowerLight)
            PaletteSampleView(palette: .warmPowerDark)
            Divider()
            PaletteSampleView(palette: .freshGrowthLight)
            PaletteSampleView(palette: .freshGrowthDark)
            Divider()
            PaletteSampleView(palette: .minimalistPunchLight)
            PaletteSampleView(palette: .minimalistPunchDark)
            Divider()
             PaletteSampleView(palette: .minimalistPunchLimeLight)
             PaletteSampleView(palette: .minimalistPunchLimeDark)
        }
    }
}
