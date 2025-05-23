//
//  AuthView.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/12/25.
//

import SwiftUI

// AuthView.swift
struct AuthView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color.theme.accent.opacity(0.3), Color.theme.background],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // App logo/branding
                    LogoView()
                        .padding(.top, 50)
                    
                    // Welcome text
                    WelcomeTextView()
                    
                    // Sign in options
                    SignInOptionsView()
                        .padding(.top, 30)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct LogoView: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 80))
                .foregroundStyle(Color.theme.accent)
            
            Text("SupaSet")
                .font(.title)
                .fontWeight(.bold)
        }
        .padding()
    }
}

struct WelcomeTextView: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("Welcome to SupaSet")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Track your workouts and achieve your fitness goals")
                .font(.subheadline)
                .foregroundColor(Color.theme.text)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}



struct Line: View {
    var body: some View {
        Rectangle()
            .fill(Color.secondary.opacity(0.3))
            .frame(height: 1)
    }
}



