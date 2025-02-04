//
//  StatCardFinished.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/30/25.
//

import SwiftUI
struct StatCardFinished: View {
    @State private var appear = false
    let title: String
    let value: Double
    let unit: String
    let gradient: LinearGradient
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            HStack(alignment: .bottom, spacing: 4) {
                Text(value.formatted(.number.precision(.fractionLength(unit == "kg" ? 1 : 0))))
                    .font(.title2.bold())
                
                Text(unit)
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 100)
        .background(gradient)
        .cornerRadius(12)
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 20)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.2)) {
                appear = true
            }
        }
    }
}
