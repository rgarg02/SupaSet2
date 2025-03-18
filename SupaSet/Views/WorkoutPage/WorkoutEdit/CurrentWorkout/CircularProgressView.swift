//
//  CircularProgressView.swift
//  SupaSet
//
//  Created by Rishi Garg on 3/18/25.
//

import SwiftUI
// Add this CircularProgressView
struct CircularProgressView: View {
    let progress: Double
    
    var body: some View {
        Circle()
            .trim(from: 0, to: progress)
            .stroke(
                .linearGradient(
                    colors: [.green, .blue],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                style: StrokeStyle(
                    lineWidth: 3,
                    lineCap: .round
                )
            )
            .rotationEffect(.degrees(-90))
            .background(
                Circle()
                    .stroke(.gray.opacity(0.2), lineWidth: 3)
            )
    }
}
