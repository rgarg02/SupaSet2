//
//  SignInOptionsView.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/12/25.
//

import SwiftUI

struct SignInOptionsView: View {
    var body: some View {
        // Provide sign in options
        VStack {
            NavigationLink{
                SignEmailView()
            } label: {
                Text("Sign in with Email")
                    .modifier(SignInButtonStyle())
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
            .foregroundColor(.white)
            .background(.blue)
            .cornerRadius(10)
            .padding()
    }
}
#Preview {
    SignInOptionsView()
}
