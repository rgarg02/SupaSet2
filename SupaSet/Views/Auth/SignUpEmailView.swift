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
    @Environment(\.alertController) private var alertController
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
                let error = error.firebaseAuthErrorMessage()
                alertController.present(message: error)
            }
        }
    }
    func signIn() {
        Task {
            do {
                try await authViewModel.signIn()
            } catch {
                let error = error.firebaseAuthErrorMessage()
                alertController.present(message: error)
            }
        }
    }
    
}
#Preview{
    NavigationStack{
        SignEmailView()
    }
}
