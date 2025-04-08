//
//  OnboardingView.swift
//  SupaSet
//
//  Created by Rishi Garg on 4/2/25.
//

import SwiftUI
import PhotosUI

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthenticationViewModel.self) private var authViewModel
    @Environment(UserManager.self) private var userManager
    @Environment(\.alertController) private var alertController
    @State private var fullName: String = ""
    @State private var bio: String = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedItemData: Data?
    @State private var profileImage: Image?
    @State private var uiImage: UIImage?
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Profile") {
                    VStack(alignment: .center) {
                        if let profileImage {
                            profileImage
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .foregroundColor(.gray)
                        }
                        
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            Text("Select Photo")
                                .foregroundColor(.blue)
                        }
                        .onChange(of: selectedItem) { _, newValue in
                            Task {
                                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                    if let uiImage = UIImage(data: data) {
                                        self.uiImage = uiImage
                                        profileImage = Image(uiImage: uiImage)
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                }
                
                Section("Personal Information") {
                    TextField("Full Name", text: $fullName)
                    
                    ZStack(alignment: .topLeading) {
                        if bio.isEmpty {
                            Text("Bio (optional)")
                                .foregroundColor(Color(.placeholderText))
                                .padding(.top, 8)
                                .padding(.leading, 5)
                        }
                        
                        TextEditor(text: $bio)
                            .frame(minHeight: 100)
                    }
                }
            }
            .navigationTitle("Complete Your Profile")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveProfile()
                    }
                    .disabled(fullName.isEmpty || isLoading)
                }
            }
            .onChange(of: selectedItem) { _, _ in
                loadImageData(from: selectedItem)
            }
        }
    }
    
    private func saveProfile() {
        guard let user = authViewModel.currentUser else {
            showError("User not authenticated")
            return
        }
        
        isLoading = true
        
        Task {
            do {
                await MainActor.run {
                    isLoading = true
                }
                
                try await userManager.createUser(email: user.email, fullName: fullName, bio: bio, newProfileImageData: selectedItemData)
                
                await MainActor.run {
                    authViewModel.authState = .authenticated
                    isLoading = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    showError(error.localizedDescription)
                }
            }
        }
    }
    private func loadImageData(from item: PhotosPickerItem?) {
        guard let item = item else { return }
        
        Task { @MainActor in // Ensure UI updates (profileImage) are on main thread
            do {
                if let data = try await item.loadTransferable(type: Data.self) {
                    selectedItemData = data // Store raw data for upload
                    if let uiImage = UIImage(data: data) {
                        profileImage = Image(uiImage: uiImage) // Update the display image state
                    } else {
                        print("⚠️ Error: Could not create UIImage from selected data.")
                        selectedItemData = nil
                        profileImage = nil
                        let alertTitle = "Image Error"
                        let alertMessage = "Could not process the selected image."
                        alertController.present(title: alertTitle, message: alertMessage)                    }
                } else {
                    print("ℹ️ No data loaded from selected item.")
                    selectedItemData = nil
                    profileImage = nil // Reset if data is nil
                }
            } catch {
                print("❌ Error loading image data: \(error)")
                selectedItemData = nil
                profileImage = nil
                let alertTitle = "Image Error"
                let alertMessage = "Failed to load the selected image: \(error.localizedDescription)"
                alertController.present(title: alertTitle, message: alertMessage)
            }
        }
    }
    
    private func showError(_ message: String) {
        alertMessage = message
        showAlert = true
    }
}

#Preview {
    OnboardingView()
        .environment(AuthenticationViewModel())
        .environment(UserManager())
}
