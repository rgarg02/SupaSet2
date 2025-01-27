//
//  AuthViewModel.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/13/25.
//

import FirebaseAuth
import CryptoKit
import AuthenticationServices
import FirebaseCore
import GoogleSignIn

enum AuthState {
    case undefined, authenticated, unauthenticated
}

extension UIApplication {
    var firstKeyWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .compactMap({$0 as? UIWindowScene})
            .filter({$0.activationState == .foregroundActive})
            .first?.windows
            .first(where: \.isKeyWindow)
    }
}

@Observable
final class AuthenticationViewModel {
    var email: String = ""
    var password: String = ""
    var authState: AuthState = .undefined
    var currentUser: User? = nil
    private var currentNonce: String?
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
    
    @MainActor
    func signInWithGoogle() async throws {
        guard let rootViewController = UIApplication.shared.firstKeyWindow?.rootViewController else {
            return
        }
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            return
        }
        let configuration = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = configuration
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        guard let idToken = result.user.idToken?.tokenString else {return}
        let accessToken = result.user.accessToken.tokenString
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        try await Auth.auth().signIn(with: credential)
    }
    // Helper method to get user email
    func getUserEmail() -> String {
        return currentUser?.email ?? "No Email"
    }
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    func configureAppleSignInRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonceString()
        currentNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
    }
    
    // Handle Apple Sign In Authentication
    func authenticateWithApple(_ authorization: ASAuthorization) async throws {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            throw NSError(domain: "AppleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid credential"])
        }
        
        guard let nonce = currentNonce else {
            throw NSError(domain: "AppleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid state: A login callback was received, but no login request was sent."])
        }
        
        guard let appleIDToken = appleIDCredential.identityToken else {
            throw NSError(domain: "AppleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to fetch identity token."])
        }
        
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            throw NSError(domain: "AppleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to login with Apple"])
        }
        
        let credential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: nonce,
            fullName: appleIDCredential.fullName
        )
        
        try await Auth.auth().signIn(with: credential)
    }
}
