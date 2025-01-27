//
//  GoogleSignIn.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/27/25.
//
import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import Firebase

struct GoogleSignIn: View {
    @Binding var isLoading: Bool
    @Environment(AuthenticationViewModel.self) private var authViewModel
    @Environment(\.alertController) private var alertController
    var body: some View {
        Button {
            Task{
                isLoading = true
                do {
                    try await authViewModel.signInWithGoogle()
                    isLoading = false
                } catch {
                    isLoading = false
                    alertController.present(error: error)
                }
            }
        } label: {
            HStack {
                Image(systemName: "g.circle.fill")
                    .font(.title3)
                Text("Continue with Google")
                    .fontWeight(.medium)
            }
            .frame(height: 55)
            .frame(maxWidth: .infinity)
            .background(.white)
            .foregroundColor(.black)
            .cornerRadius(10)
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.white, lineWidth: 1)
                
            }
        }
    }
}
