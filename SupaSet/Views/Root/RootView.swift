//
//  RootView.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/12/25.
//

import SwiftUI
import FirebaseAuth
struct RootView: View {
    @Environment(AuthenticationViewModel.self) var authViewModel
    var body: some View {
        Group {
            switch authViewModel.authState {
            case .undefined:
                ProgressView()
            case .unauthenticated:
                AuthView()
            case .authenticated:
                ContentView()
            }
        }
    }
}
