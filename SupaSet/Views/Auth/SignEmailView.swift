//
//  SignEmailView.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/26/25.
//

import SwiftUI
// SignEmailView.swift
struct SignEmailView: View {
    @Environment(AuthenticationViewModel.self) var authViewModel
    @State private var isSignUp = false
    @State private var isAnimating = false
    @State private var isLoading = false
    @Environment(\.alertController) private var alertController
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password
    }
    
    var body: some View {
        LoadingView(isShowing: $isLoading) {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text(isSignUp ? "Create Account" : "Welcome Back")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.theme.text)
                    
                    Text(isSignUp ? "Sign up to get started" : "Sign in to continue")
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Form fields
                VStack(spacing: 16) {
                    CustomTextField(
                        icon: "envelope.fill",
                        placeholder: "Email",
                        text: Bindable(authViewModel).email
                    )
                    .focused($focusedField, equals: .email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disabled(isLoading)
                    
                    CustomSecureField(
                        icon: "lock.fill",
                        placeholder: "Password",
                        text: Bindable(authViewModel).password
                    )
                    .focused($focusedField, equals: .password)
                    .disabled(isLoading)
                }
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 20)
                
                // Action buttons
                VStack(spacing: 16) {
                    Button {
                        authenticate()
                    } label: {
                        Text(isSignUp ? "Create Account" : "Sign In")
                            .modifier(SignInButtonStyle())
                    }
                    .disabled(isLoading)
                    
                    Button {
                        withAnimation {
                            isSignUp.toggle()
                        }
                    } label: {
                        Text(isSignUp ? "Already have an account? Sign in" : "Don't have an account? Sign up")
                            .foregroundColor(.blue)
                            .font(.subheadline)
                    }
                    .disabled(isLoading)
                }
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 20)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                withAnimation(.easeOut(duration: 0.5)) {
                    isAnimating = true
                }
            }
            .onChange(of: authViewModel.authState) { _, isAuthenticated in
                switch isAuthenticated {
                case .authenticated:
                    isLoading = false
                    dismiss()
                default:
                    break
                }
            }
        }
    }
    
    private func authenticate() {
        isLoading = true
        Task {
            do {
                if isSignUp {
                    try await authViewModel.signUp()
                } else {
                    try await authViewModel.signIn()
                }
                try modelContext.delete(model: Workout.self)
                try modelContext.delete(model: WorkoutExercise.self)
                try modelContext.delete(model: ExerciseSet.self)
                try modelContext.delete(model: ExerciseDetail.self)
                try modelContext.delete(model: Template.self)
                try modelContext.delete(model: TemplateExercise.self)
                try modelContext.delete(model: TemplateExerciseSet.self)
            } catch {
                isLoading = false
                let error = error.firebaseAuthErrorMessage()
                alertController.present(message: error)
            }
        }
    }
}

// Add this new LoadingView
struct LoadingView<Content>: View where Content: View {
    @Binding var isShowing: Bool
    var content: () -> Content
    
    var body: some View {
        ZStack {
            content()
                .disabled(isShowing)
                .blur(radius: isShowing ? 1 : 0)
            
            if isShowing {
                ZStack {
                    Color.black.opacity(0.1)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(Color.theme.accent)
//                        
//                        Text("Please wait...")
//                            .foregroundColor(.secondary)
//                            .font(.subheadline)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(Color.theme.background))
                            .shadow(radius: 10)
                    )
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isShowing)
    }
}

// Update CustomTextField and CustomSecureField to handle disabled state
struct CustomTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 40)
            
            TextField(placeholder, text: $text)
        }
        .frame(height: 55)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .opacity(self.text.isEmpty ? 0.8 : 1.0)
    }
}

struct CustomSecureField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    @State private var isSecured = true
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 40)
            
            Group {
                if isSecured {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            
            Button {
                withAnimation {
                    isSecured.toggle()
                }
            } label: {
                Image(systemName: isSecured ? "eye.slash" : "eye")
                    .foregroundColor(.secondary)
                    .contentTransition(.symbolEffect(.replace))
            }
            .padding(.horizontal)
        }
        .frame(height: 55)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .opacity(self.text.isEmpty ? 0.8 : 1.0)
    }
}

#Preview{
    SignEmailView()
        .environment(AuthenticationViewModel())
}
