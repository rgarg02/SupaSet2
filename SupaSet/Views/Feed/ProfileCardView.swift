//
//  ProfileCardView.swift
//  SupaSet
//
//  Created by Rishi Garg on 4/3/25.
//


import SwiftUI
import FirebaseFirestore // For DocumentSnapshot

struct ProfileCardView: View {
    let user: User
    @Environment(UserManager.self) var userManager
    @State private var isFollowing: Bool = false
    @State private var isCheckingFollowStatus: Bool = true // Start checking initially
    @State private var isUpdatingFollowStatus: Bool = false // For follow/unfollow action

    var body: some View {
        VStack(spacing: 8) {
            // Profile Image (using AsyncImage for URL loading)
            if let profilePicUrl = user.profilePicUrl {
                AsyncImage(url: URL(string: profilePicUrl)) { phase in
                    switch phase {
                    case .empty:
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                            .foregroundColor(.gray)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                    case .failure:
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                // Placeholder if no profile picture URL
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .foregroundColor(.gray)
            }
            // Username
            Text(user.fullName)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(1)

            // Follow/Unfollow Button (Only if not the current user)
            if user.id != userManager.user?.id {
                Button {
                    Task { await toggleFollowStatus() }
                } label: {
                    Text(isUpdatingFollowStatus ? "" : (isFollowing ? "Following" : "Follow"))
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .foregroundColor(isFollowing ? .primary : .white) // Text color
                        .background(isFollowing ? Color(.systemGray5) : Color.blue) // Background color
                        .clipShape(Capsule())
                }
                .disabled(isCheckingFollowStatus || isUpdatingFollowStatus) // Disable while busy
                .overlay { // Show activity indicator when updating
                    if isUpdatingFollowStatus {
                        ProgressView()
                            .scaleEffect(0.5) // Make spinner smaller
                    }
                }
            } else {
                 // Optionally show something else for the current user,
                 // or just empty space to maintain layout
                 Spacer().frame(height: 20) // Adjust height to match button
            }
        }
        .padding(10) // Padding inside the card
        .frame(width: 110) // Fixed width for cards
        .background(Color(.secondarySystemBackground)) // Card background
        .cornerRadius(10)
        .onAppear {
            // Check initial follow status when the card appears
            // Only check if it's not the current user
            if user.id != userManager.user?.id {
                 Task { await checkFollowStatus() }
            } else {
                isCheckingFollowStatus = false // No need to check for self
            }
        }
        .onChange(of: userManager.user?.followingCount) { _ , _ in
             // Re-check if the global following count changes
             // (e.g., if follow happens elsewhere)
             // This is an optimization, you might not need it if
             // the Task below handles updates well enough.
             if user.id != userManager.user?.id {
                 Task { await checkFollowStatus() }
             }
        }
    }

    // Function to check if current user is following this profile
    private func checkFollowStatus() async {
        let userId = user.id
        // No need to set isCheckingFollowStatus = true here,
        // it starts true or is set true before calling.
        // Avoid flickering by not setting it false immediately.
        do {
            let result = try await userManager.isFollowing(otherUserID: userId)
             // Update state on the main thread
             await MainActor.run {
                 self.isFollowing = result
                 self.isCheckingFollowStatus = false
             }
        } catch {
             await MainActor.run {
                 print("❌ Error checking follow status for \(userId): \(error.localizedDescription)")
                 self.isCheckingFollowStatus = false // Ensure loading stops on error
             }
        }
    }

    // Function to follow or unfollow the user
    private func toggleFollowStatus() async {
        guard !isUpdatingFollowStatus else { return }
        let userId = user.id
        await MainActor.run { isUpdatingFollowStatus = true }

         do {
             if isFollowing {
                 // Perform Unfollow
                 try await userManager.unfollow(userToUnfollowID: userId)
                 await MainActor.run { isFollowing = false }
             } else {
                 // Perform Follow
                 try await userManager.follow(userToFollowID: userId)
                 await MainActor.run { isFollowing = true }
             }
         } catch {
              await MainActor.run {
                  print("❌ Error updating follow status for \(userId): \(error.localizedDescription)")
                  // Optionally show an error to the user
              }
         }

        await MainActor.run { isUpdatingFollowStatus = false }
        // Optionally re-run checkFollowStatus for belt-and-braces verification,
        // though the state should be correct now.
        // Task { await checkFollowStatus() }
     }
}
