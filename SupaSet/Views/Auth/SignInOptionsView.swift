//
//  SignInOptionsView.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/12/25.
//

import SwiftUI

// SignInOptionsView.swift
struct SignInOptionsView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Social sign-in options
            Group {
                SocialSignInButton(
                    title: "Continue with Apple",
                    icon: "apple.logo",
                    backgroundColor: .black
                )
                
                SocialSignInButton(
                    title: "Continue with Google",
                    icon: "g.circle.fill",
                    backgroundColor: .white,
                    foregroundColor: .black,
                    borderColor: .gray.opacity(0.3)
                )
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
    }
}
// Create style for sign in button
struct SignInButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .frame(height: 55)
            .frame(maxWidth: .infinity)
            .foregroundColor(Color.theme.textOpposite)
            .background(Color.theme.primary)
            .cornerRadius(10)
            .padding()
    }
}
#Preview {
    SignInOptionsView()
}
