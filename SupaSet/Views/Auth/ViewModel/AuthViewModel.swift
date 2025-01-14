//
//  AuthViewModel.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/13/25.
//

import FirebaseAuth

enum AuthState {
    case undefined, authenticated, unauthenticated
}
@Observable
final class AuthenticationViewModel {
    var email: String = ""
    var password: String = ""
    var authState: AuthState = .undefined
    func listenToAuthChanges() {
        Auth.auth().addStateDidChangeListener { _, user in
            self.authState = user != nil ? .authenticated : .unauthenticated
        }
    }
    func signIn() async throws {
        // Sign in with email
        try await Auth.auth().signIn(withEmail: email, password: password)
    }
    func signUp() async throws {
        // Sign up with email
        try await Auth.auth().createUser(withEmail: email, password: password)
    }
    func signOut() throws {
        // Sign out
        try Auth.auth().signOut()
    }
}
