//
//  EditProfileView.swift
//  SupaSet
//
//  Created by Rishi Garg on 4/2/25. // Or your current date
//

import SwiftUI
import PhotosUI // Needed for PhotosPicker
import FirebaseFirestore // Needed if you reference Timestamp directly, but likely not here

struct EditProfileView: View {
    // Use UserManager from Environment (ensure it's provided by a parent view)
    @Environment(UserManager.self) private var userManager
    @Environment(\.dismiss) var dismiss // To close the sheet
    @Environment(\.alertController) private var alertController
    // State to hold the user data fetched from UserManager
    @Binding var currentUser: User?

    // Local State for Editable Fields
    @State private var editedFullName: String = ""
    @State private var editedBio: String = ""
    @State private var editedIsPublic: Bool = false

    // State for Photo Picker
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImageData: Data? // Holds data for the *newly* selected image
    @State private var profileImage: Image? // Holds the Image view to display

    // State for UI feedback
    @State private var isLoading: Bool = true // Start in loading state
    @State private var isSaving: Bool = false

    // Constants
    private let profileImageSize: CGFloat = 100

    var body: some View {
        NavigationView { // Embed in NavigationView for Toolbar
            Group { // Use Group to switch between loading and content
                if isLoading {
                    ProgressView("Loading Profile...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if currentUser == nil {
                    ContentUnavailableView(
                        "Could Not Load Profile",
                         systemImage: "person.crop.circle.badge.exclamationmark",
                         description: Text("Failed to load your profile data. Please check your connection and try again.")
                    )
                } else {
                    formContent // Extracted Form content
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Cancel Button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.red) // Make cancel visually distinct
                }
                // Save Button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task { await saveProfile() }
                    } label: {
                        if isSaving {
                            ProgressView()
                                .tint(.accentColor)
                        } else {
                            Text("Save")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(isSaving || isLoading || !hasChanges()) // Disable if saving, loading, or no changes
                }
            }
            .task { await loadInitialUserData() } // Use .task for async onAppear
            .onChange(of: selectedPhotoItem, perform: loadImageData) // Load data when picker item changes
        }
        // Make sure UserManager is injected in the parent view (e.g., .environment(UserManager()))
    }

    // MARK: - Form Content View
    private var formContent: some View {
        Form {
            // --- Profile Picture Section ---
            Section {
                HStack {
                    Spacer()
                    VStack(spacing: 15) {
                        profileImageView
                            .frame(width: profileImageSize, height: profileImageSize)
                            .background(Color(.systemGray6)) // Placeholder background
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))

                        PhotosPicker(
                            selection: $selectedPhotoItem,
                            matching: .images, // Only pick images
                            photoLibrary: .shared() // Use the shared library
                        ) {
                            Text("Change Photo")
                                .font(.footnote)
                                .foregroundColor(.accentColor)
                        }
                    }
                    Spacer()
                }
                .listRowBackground(Color.clear) // Make row background transparent
                .padding(.vertical) // Add some vertical padding
            }

            // --- Details Section ---
            Section("Public Profile") {
                TextField("Full Name", text: $editedFullName)
                    .textContentType(.name)
                    .autocorrectionDisabled()

                VStack(alignment: .leading) {
                    Text("Bio")
                        .font(.caption)
                        .foregroundStyle(.gray)
                    TextEditor(text: $editedBio)
                        .frame(height: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color(.systemGray5), lineWidth: 1)
                        )
                }
                .padding(.vertical, 4)

                Toggle("Public Account", isOn: $editedIsPublic)
                    .tint(.accentColor)
            }

            // --- Read-only Info (Example) ---
             Section("Account") {
                 HStack {
                     Text("Email")
                     Spacer()
                     Text(currentUser?.email ?? "N/A") // Use currentUser state
                         .foregroundColor(.gray)
                 }
             }
        }
    }


    // MARK: - Computed Properties

    /// Determines the view to display for the profile image.
    private var profileImageView: some View {
        Group {
            if let profileImage { // Display newly selected/loaded image
                profileImage
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if let urlString = currentUser?.profilePicUrl, let url = URL(string: urlString) {
                // Use AsyncImage for existing URL from currentUser state
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        placeholderImage // Show placeholder on failure
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                placeholderImage // Default placeholder
            }
        }
    }

    /// The placeholder image view.
    private var placeholderImage: some View {
         Image(systemName: "person.circle.fill") // Use system image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundStyle(.gray.opacity(0.5))
            .padding(profileImageSize * 0.1) // Add padding if using system image directly
    }

    // MARK: - Helper Functions

    /// Fetches current user data using UserManager and populates state.
    @MainActor
    private func loadInitialUserData() async {
        // Only load if currentUser hasn't been loaded yet or explicitly needed
        guard currentUser == nil else {
            editedFullName = currentUser?.fullName ?? ""
            editedBio = currentUser?.bio ?? ""
            editedIsPublic = currentUser?.isPublic ?? false
            isLoading = false
            return
        }

        isLoading = true
        if let user = userManager.user {
            self.currentUser = user // Store the fetched user
            // Populate editable fields from the fetched user
            editedFullName = user.fullName
            editedBio = user.bio ?? ""
            editedIsPublic = user.isPublic
            isLoading = false
        }
    }


    /// Loads image data from the selected PhotosPickerItem.
    private func loadImageData(from item: PhotosPickerItem?) {
        guard let item = item else { return }

        Task { @MainActor in // Ensure UI updates (profileImage) are on main thread
            do {
                if let data = try await item.loadTransferable(type: Data.self) {
                    selectedImageData = data // Store raw data for upload
                    if let uiImage = UIImage(data: data) {
                        profileImage = Image(uiImage: uiImage) // Update the display image state
                    } else {
                        print("⚠️ Error: Could not create UIImage from selected data.")
                        selectedImageData = nil
                        profileImage = nil
                        let alertTitle = "Image Error"
                        let alertMessage = "Could not process the selected image."
                        alertController.present(title: alertTitle, message: alertMessage)                    }
                } else {
                    print("ℹ️ No data loaded from selected item.")
                     selectedImageData = nil
                     profileImage = nil // Reset if data is nil
                }
            } catch {
                 print("❌ Error loading image data: \(error)")
                 selectedImageData = nil
                 profileImage = nil
                 let alertTitle = "Image Error"
                 let alertMessage = "Failed to load the selected image: \(error.localizedDescription)"
                alertController.present(title: alertTitle, message: alertMessage)
            }
        }
    }

    /// Checks if any editable field has changed from the original user data.
    private func hasChanges() -> Bool {
        // Ensure we have the original user data to compare against
        guard let originalUser = currentUser else { return false }

        // Check text fields, toggle, and if a new image was selected
        // Treat empty bio as potentially different from nil bio if needed by backend,
        // but here we compare editedBio (which could be "") with originalUser.bio ?? ""
        return editedFullName != originalUser.fullName ||
               editedBio != (originalUser.bio ?? "") ||
               editedIsPublic != originalUser.isPublic ||
               selectedImageData != nil // Check if new image data exists
    }

    // MARK: - Actions

    /// Gathers the edited data and calls the UserManager to save it.
    @MainActor
    private func saveProfile() async {
        guard let originalUser = currentUser else {
            let alertTitle = "Error"
            let alertMessage = "Cannot save profile. Original user data is missing."
            alertController.present(title: alertTitle, message: alertMessage)
            return
        }

        guard hasChanges() else {
            dismiss()
            return
        }

        isSaving = true

        // --- Prepare data for UserManager ---
        // Only pass values if they actually changed from the original.
        // This prevents unnecessary writes and ensures `updatedAt` only changes when needed.
        let finalFullName = editedFullName != originalUser.fullName ? editedFullName.trimmingCharacters(in: .whitespacesAndNewlines) : nil

        let trimmedBio = editedBio.trimmingCharacters(in: .whitespacesAndNewlines)
        let originalBio = originalUser.bio ?? "" // Treat nil original bio as empty string for comparison
        // Pass nil if bio is empty *and* original was empty/nil, otherwise pass trimmed value (which becomes nil if empty)
        let finalBio: String?? = trimmedBio != originalBio ? (trimmedBio.isEmpty ? .some(nil) : .some(trimmedBio)) : .none
        // If finalBio == .some(nil), it means "set bio to null"
        // If finalBio == .some("text"), it means "set bio to text"
        // If finalBio == .none, it means "don't update bio"


        let finalIsPublic = editedIsPublic != originalUser.isPublic ? editedIsPublic : nil

        // --- End Prepare data ---

        do {
            try await userManager.updateUserProfile(
                fullName: finalFullName,
                bio: finalBio == .none ? nil : (finalBio == .some(nil) ? nil : finalBio!), // Pass nil if no change, or the actual value/nil if changed
                isPublic: finalIsPublic,
                newProfileImageData: selectedImageData // Pass the UIImage?
            )
            currentUser = userManager.user
            // Success
            isSaving = false
            dismiss()

        } catch {
            // Failure
            isSaving = false
            let alertTitle = "Update Failed"
            let alertMessage = "Failed to update profile: \(error.localizedDescription)"
            alertController.present(title: alertTitle, message: alertMessage)
        }
    }
}

