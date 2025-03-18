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
    @Environment(ExerciseViewModel.self) var exerciseViewModel
    @Environment(\.modelContext) private var modelContext
    
    @State private var userProfileViewModel: UserProfileViewModel?
    @State private var isOnboardingComplete = false
    
    var body: some View {
            Group {
                switch authViewModel.authState {
                case .undefined:
                    ProgressView()
                case .unauthenticated:
                    AuthView()
                    
                case .authenticated:
                    if shouldShowOnboarding() {
                        OnboardingView(isOnboardingComplete: $isOnboardingComplete, modelContext: modelContext)
                            .transition(.opacity)
                    } else {
                        ContentView()
                            .transition(.opacity)
                    }
                }
            }
            .onAppear {
                userProfileViewModel = UserProfileViewModel(modelContext: modelContext)
            }
            .animation(.easeInOut, value: authViewModel.authState)
            .animation(.easeInOut, value: isOnboardingComplete)
            .onChange(of: isOnboardingComplete) { _, newValue in
                if newValue {
                    // User completed onboarding, refresh the state
                    Task {
                        try? await userProfileViewModel?.loadUserProfile()
                    }
                }
            }
    }
    
    private func shouldShowOnboarding() -> Bool {
        // If this is a new user (based on creation date) or no user profile exists
        if let creationDate = authViewModel.getUserCreationDate() {
            // User is new if account was created less than 1 hour ago
//            let isNewUser = creationDate.timeIntervalSinceNow > -3600
            
//            if isNewUser {
                return userProfileViewModel?.hasCompletedOnboarding() == false
//            }
        }
        
        // Check if profile exists at all
        return userProfileViewModel?.hasCompletedOnboarding() == false
    }
}
