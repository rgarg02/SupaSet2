//
//  RootView.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/12/25.
//

import SwiftUI
import FirebaseAuth
import SwiftData

struct RootView: View {
    @Environment(AuthenticationViewModel.self) var authViewModel
    @Environment(\.modelContext) private var modelContext
        
    var body: some View {
            Group {
                switch authViewModel.authState {
                case .undefined:
                    ProgressView()
                case .unauthenticated:
                    AuthView()
                case .authenticatedNewUser:
                    OnboardingView()
                case .authenticated:
                    ContentView()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut, value: authViewModel.authState)
    }
    
}
