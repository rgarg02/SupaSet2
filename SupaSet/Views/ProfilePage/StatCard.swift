//
//  StatCard.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/27/25.
//


import SwiftUI
// Supporting Views
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.theme.accent)
            
            Text(value)
                .font(.title2)
                .foregroundColor(.theme.text)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.theme.text)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.theme.background)
                .shadow(color: Color.theme.text, radius: 1)
        )
    }
}

#Preview {
    HStack(spacing: 20) {
        StatCard(title: "Workouts", value: "0", icon: "dumbbell.fill")
        StatCard(title: "Hours", value: "0", icon: "clock.fill")
        StatCard(title: "Streak", value: "0", icon: "flame.fill")
    }
}
