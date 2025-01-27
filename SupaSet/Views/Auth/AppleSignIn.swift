//
//  AppleSignIn.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/27/25.
//

// In AppleSignIn.swift

import SwiftUI
import AuthenticationServices

struct AppleSignIn: View {
    @Binding var isLoading: Bool
    @Environment(\.alertController) private var alertController
    @Environment(AuthenticationViewModel.self) private var authViewModel
    
    var body: some View {
        SignInWithAppleButton(.signIn) { request in
            authViewModel.configureAppleSignInRequest(request)
        } onCompletion: { result in
            handleSignInCompletion(result)
        }
        .frame(height: 55)
        .frame(maxWidth: .infinity)
        .background(.black)
        .foregroundColor(.white)
        .cornerRadius(10)
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(.black, lineWidth: 1)
        }
    }
    
    private func handleSignInCompletion(_ result: Result<ASAuthorization, Error>) {
        isLoading = true
        
        Task {
            do {
                switch result {
                case .success(let authorization):
                    try await authViewModel.authenticateWithApple(authorization)
                case .failure(let error):
                    alertController.present(error: error)
                }
            } catch {
                alertController.present(error: error)
            }
            isLoading = false
        }
    }
}
