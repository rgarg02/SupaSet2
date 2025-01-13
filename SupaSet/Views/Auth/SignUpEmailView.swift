//
//  EmailView.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/12/25.
//

import SwiftUI
import Observation


struct SignEmailView: View {
    @Environment(AuthenticationViewModel.self) var authViewModel
    @State var email: String = ""
    @State var password: String = ""
    @State var isSignUp: Bool = false
    @State var showEmailAlert: Bool = false
    @State var emailError: String = ""
    var body: some View {
        VStack{
            TextField("Email", text: Bindable(authViewModel).email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            SecureField("Password", text:  Bindable(authViewModel).password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button {
                authenticate()
            } label: {
                Text("\(isSignUp ? "Sign Up" : "Sign In") with Email")
            }
            .modifier(SignInButtonStyle())
            Button {
                isSignUp.toggle()
            } label: {
                Text(isSignUp ? "Already have an account? Sign in" : "Don't have an account? Sign up")
            }
        }
        .alert("Error", isPresented: $showEmailAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(emailError)
        }
        .navigationTitle("Sign in with Email")
    }
    func authenticate() {
        isSignUp ? signUp() : signIn()
    }
    func signUp() {
        Task {
            do {
                try await authViewModel.signUp()
            } catch {
                showEmailAlert = true
                emailError = error.localizedDescription
            }
        }
    }
    func signIn() {
        Task {
            do {
                try await authViewModel.signIn()
            } catch {
                showEmailAlert = true
                emailError = error.localizedDescription
            }
        }
    }
}
#Preview{
    NavigationStack{
        SignEmailView()
    }
}
