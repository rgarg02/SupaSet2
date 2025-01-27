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
    var currentUser: User? = nil
    
    
    func listenToAuthChanges() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.currentUser = user
            self?.authState = user != nil ? .authenticated : .unauthenticated
        }
    }
    
    func signIn() async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }
    
    func signUp() async throws {
        try await Auth.auth().createUser(withEmail: email, password: password)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    // Helper method to get user creation date
    func getUserCreationDate() -> Date? {
        return currentUser?.metadata.creationDate
    }
    
    // Helper method to get user email
    func getUserEmail() -> String {
        return currentUser?.email ?? "No Email"
    }
}
