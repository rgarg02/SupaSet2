//
//  SignInOptionsView.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/12/25.
//

import SwiftUI
import AuthenticationServices
// SignInOptionsView.swift
struct SignInOptionsView: View {
    @State private var isAnimating = false
    @State private var isLoading = false
    @Environment(\.alertController) private var alertController
    var body: some View {
        VStack(spacing: 16) {
            // Social sign-in options
            Group {
                AppleSignIn(isLoading: $isLoading)
                
                GoogleSignIn(isLoading: $isLoading)
            }
            .opacity(isAnimating ? 1 : 0)
            .offset(y: isAnimating ? 0 : 20)
            
            // Divider
            HStack {
                Line()
                Text("or")
                    .foregroundColor(.secondary)
                    .font(.footnote)
                Line()
            }
            .padding(.vertical)
            
            // Email sign-in
            NavigationLink {
                SignEmailView()
            } label: {
                HStack {
                    Image(systemName: "envelope.fill")
                    Text("Continue with Email")
                }
                .modifier(SignInButtonStyle())
            }
            .opacity(isAnimating ? 1 : 0)
            .offset(y: isAnimating ? 0 : 20)
        }
        .padding(.horizontal)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                isAnimating = true
            }
        }
        .overlay {
            if isLoading {
                LoadingScreen()
            }
        }
    }
}

struct LoadingScreen: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.1)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(Color.theme.accent)
//
//                        Text("Please wait...")
//                            .foregroundColor(.secondary)
//                            .font(.subheadline)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(Color.theme.background))
                    .shadow(radius: 10)
            )
        }
        .transition(.opacity)
    }
}
// Create style for sign in button
struct SignInButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .frame(height: 55)
            .frame(maxWidth: .infinity)
            .foregroundColor(Color.background)
            .background(Color.theme.primary)
            .cornerRadius(10)
            .padding()
    }
}
#Preview {
    SignInOptionsView()
}
