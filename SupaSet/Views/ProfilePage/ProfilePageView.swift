//
//  HomeView.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/5/24.
//

import SwiftUI

struct ProfilePageView: View {
    @Environment(AuthenticationViewModel.self) var authViewModel
    @State private var showSignOutAlert = false
    @State private var signOutError: Error?
    var body: some View {
        VStack{
            Text("Profile Page")
            Button("Sign Out") {
                do{
                   try authViewModel.signOut()
                } catch {
                    signOutError = error
                    showSignOutAlert = true
                }
            }
        }
        .alert(isPresented: $showSignOutAlert) {
            Alert(title: Text("Error Signing Out"), message: Text(signOutError?.localizedDescription ?? "An error occurred while signing out. Please try again."), dismissButton: .default(Text("OK")))
        }
    }
}

#Preview {
    ProfilePageView()
}
