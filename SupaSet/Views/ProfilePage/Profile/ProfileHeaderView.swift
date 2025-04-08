//
//  ProfileHeaderView.swift
//  SupaSet
//
//  Created by Rishi Garg on 4/2/25. // Or your current date
//

import SwiftUI

struct ProfileHeaderView: View {
    // Assuming AlertController is still needed for error handling
    @Environment(\.alertController) private var alertController
    @Environment(UserManager.self) private var userManager
    // Constants for image size
    private let imageSize: CGFloat = 100
    
    var body: some View {
        VStack(spacing: 16) {
            // Profile Image - Now uses AsyncImage or placeholder
            profileImageView // Use the computed property
            // User Info
            userInfoView // Extracted user info VStack
            
        }
        .padding(.vertical) // Add vertical padding
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Subviews
    
    /// Displays the user's profile image using AsyncImage or a placeholder.
    @ViewBuilder
    private var profileImageView: some View {
        // Check if user data is loaded and if a profile URL exists
        if let urlString = userManager.user?.profilePicUrl, let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    // Placeholder while loading
                    ProgressView()
                        .frame(width: imageSize, height: imageSize)
                        .background(Color(.systemGray5)) // Use a subtle background
                        .clipShape(Circle())
                case .success(let image):
                    // Display loaded image
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill) // Fill the circle
                        .frame(width: imageSize, height: imageSize)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1)) // Optional border
                case .failure:
                    // Fallback on failure
                    initialsPlaceholderView
                @unknown default:
                    // Fallback for future cases
                    initialsPlaceholderView
                }
            }
        } else {
            // Fallback if no URL or user data not loaded yet
            initialsPlaceholderView
        }
    }
    
    /// Displays the placeholder view with initials.
    private var initialsPlaceholderView: some View {
        ZStack {
            Circle()
                .fill(Color("PrimaryThemeColorTwo", bundle: nil).opacity(0.8)) // Use asset catalog color safely
                .frame(width: imageSize, height: imageSize)
                .shadow(color: Color.black.opacity(0.2), radius: 3, y: 2) // Adjusted shadow
            if let emailInitial = userManager.user?.email?.first {
                Text(String(emailInitial).uppercased())
                    .font(.system(size: imageSize * 0.45)) // Scale font size with image size
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.9)) // Use white or contrasting color
            } else {
                // Fallback icon if no email is available either
                Image(systemName: "person.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: imageSize * 0.5, height: imageSize * 0.5)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .task {
            do {
                try await userManager.getCurrentUser()
            } catch {
                alertController.present(error: error)
            }
        }
    }
    
    /// Displays user's name and membership date.
    @ViewBuilder
    private var userInfoView: some View {
        VStack(spacing: 4) {
            // Use full name first, fallback to email
            Text(userManager.user?.fullName ?? "User")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary) // Use primary text color
                .lineLimit(1)
                .truncationMode(.tail) // Use tail truncation generally
            
            // Display membership date if available
            if let date = userManager.user?.createdAt?.dateValue() {
                Text("Member since \(formatDate(date))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
        }
    }
    
    // MARK: - Helper Functions
    
    /// Formats the date into a medium style string.
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
