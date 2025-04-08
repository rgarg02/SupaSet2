//
//  MeshGradientBackground.swift
//  SupaSet
//
//  Created by Rishi Garg on 3/31/25.
//

import SwiftUI

enum AppData {
    static var colors: [Color] = [
        Color("TertiaryTwo"),
        Color("TertiaryTwo"),
        Color("TertiaryTwo"),
        Color("PrimaryThemeColor"),
        Color("PrimaryThemeColor"),
        Color("PrimaryThemeColor"),
        Color("TertiaryTwo"),
        Color("PrimaryThemeColor"),
        Color("TertiaryTwo"),
        Color("TertiaryTwo"),
        Color("PrimaryThemeColor"),
        Color("PrimaryThemeColor"),
        ]
    static var points: [SIMD2<Float>] {
        [
                .init(0.00, 0.00),.init(0.36, 0.00),.init(0.70, 0.00),.init(1.00, 0.00),
    .init(0.00, 0.44),.init(0.34, 0.26),.init(0.64, 0.70),.init(1.00, 0.93),
    .init(0.00, 1.00),.init(0.01, 1.00),.init(0.54, 1.00),.init(1.00, 1.00)
                ]
    }
}

struct MeshGradientBackground: View {
    @State var points: [SIMD2<Float>] = AppData.points
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.background)
        }
    }
}
#Preview {
    Group {
        MeshGradientBackground()
            .colorScheme(.light)
        MeshGradientBackground()
            .colorScheme(.dark)
    }
}
