//
//  DiscoverPeopleCarouselView.swift
//  SupaSet
//
//  Created by Rishi Garg on 4/4/25.
//

import SwiftUI
import FirebaseFirestore
struct DiscoverPeopleCarouselView: View {
    @Environment(UserManager.self) private var userManager
    @Environment(\.alertController) private var alertController
    // State for the discovered users
    @State private var discoveredUsers: [User] = []
    @State private var isLoading: Bool = false
    @State private var lastDocumentSnapshot: DocumentSnapshot? = nil
    @State private var canLoadMoreUsers: Bool = false // Flag to know if pagination is possible
    let pageSize = 10 // Number of users to fetch per page
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(discoveredUsers) { user in
                    ProfileCardView(user: user)
                }
                if canLoadMoreUsers {
                    Button {
                        Task { await loadMoreUsers() }
                    } label: {
                        VStack {
                            Image(systemName: "arrow.right.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                                .foregroundColor(.blue)
                            Text("More")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        .frame(width: 110, height: 130) // Match card height roughly
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    .disabled(isLoading) // Disable while loading more
                }
                // Optional: Show a loading indicator at the end while fetching more
                if isLoading && !discoveredUsers.isEmpty {
                    ProgressView()
                        .frame(width: 110, height: 130)
                }
            }
            .padding(.horizontal) // Padding for the HStack content
            .padding(.vertical, 5) // Small vertical padding for the scroll view
        }
        .onAppear {
            // Load initial users only if the list is empty
            if discoveredUsers.isEmpty {
                Task {
                    await loadInitialUsers()
                }
            }
            // Also ensure current user data is loaded if needed by ProfileCardView
            if userManager.user == nil {
                Task { try? await userManager.getCurrentUser() }
            }
        }
        .frame(height: 150) // Set a fixed height for the horizontal scroll area
    }
    // Function to load the first page of users
    private func loadInitialUsers() async {
        guard !isLoading else { return } // Prevent simultaneous loads
        
        isLoading = true
        canLoadMoreUsers = true // Reset pagination state
        lastDocumentSnapshot = nil // Reset snapshot for first page
        
        do {
            let result = try await userManager.fetchPublicUsers(
                pageSize: pageSize,
                lastDocumentSnapshot: nil // Start from the beginning
            )
            print("loading")
            // Filter out the current user from the discovery list
            let currentUserID = userManager.user?.id
            let fetchedUsers = result.users.filter { $0.id != currentUserID }
            
            
            await MainActor.run {
                self.discoveredUsers = fetchedUsers
                self.lastDocumentSnapshot = result.lastSnapshot
                // If fewer users were returned than requested, we've reached the end
                self.canLoadMoreUsers = result.users.count == pageSize
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                alertController.present(error: error)
                self.isLoading = false
            }
        }
    }
    
    // Function to load subsequent pages of users
    private func loadMoreUsers() async {
        // Don't load more if already loading, or if we know there are no more pages
        guard !isLoading, canLoadMoreUsers else { return }
        
        isLoading = true
        
        do {
            let result = try await userManager.fetchPublicUsers(
                pageSize: pageSize,
                lastDocumentSnapshot: lastDocumentSnapshot // Use the last snapshot
            )
            
            // Filter out the current user from the newly fetched list
            let newUsers = result.users
            
            await MainActor.run {
                // Append the new users to the existing list
                self.discoveredUsers.append(contentsOf: newUsers)
                self.lastDocumentSnapshot = result.lastSnapshot
                // If fewer users were returned than requested, we've reached the end
                self.canLoadMoreUsers = result.users.count == pageSize
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                alertController.present(error: error)
                self.isLoading = false
            }
        }
    }
}

