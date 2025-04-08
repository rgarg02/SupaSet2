//
//  FeedView.swift
//  SupaSet
//
//  Created by Rishi Garg on 4/3/25.
//


import SwiftUI
import FirebaseFirestore // For DocumentSnapshot

struct FeedView: View {
    // Use @StateObject for the UserManager instance if FeedView owns it,
    // or @ObservedObject if it's passed from a parent view.
    @Environment(UserManager.self) private var userManager
    @State private var workoutFeedItems: [WorkoutFeedItem] = []
    @Environment(\.alertController) private var alertController
    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    Text("Discover People")
                        .font(.headline)
                        .padding(.horizontal)
                        .padding(.top)
                    DiscoverPeopleCarouselView()
                    // --- Other Feed Content ---
                    Divider().padding(.horizontal)
                    WorkoutFeed(feedItems: workoutFeedItems)
                    Spacer() // Pushes content to the top
                }
                .padding(.bottom, 55)
            }
            .task {
                // Fetch only if empty on initial appearance
                if workoutFeedItems.isEmpty {
                    await fetchWorkouts()
                }
            }
            .refreshable(action: {
                await fetchWorkouts()
            })
            .background(MeshGradientBackground().ignoresSafeArea())
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    func fetchWorkouts() async {
        // Clear previous items on refresh
        // self.feedItems.removeAll() // Uncomment if you want a blank screen during refresh
        
        do {
            // 1. Fetch public workouts (WorkoutFS objects)
            // Ensure WorkoutService.fetchPublicWorkouts() exists and returns [WorkoutFS]
            let workoutsFS = try await WorkoutService.fetchPublicWorkouts()
            
            // 2. Fetch users concurrently using TaskGroup or async let
            var items: [WorkoutFeedItem] = []
            try await withThrowingTaskGroup(of: WorkoutFeedItem?.self) { group in
                for workoutFS in workoutsFS {
                    // Add a task to the group to fetch the user for this workout
                    group.addTask {
                        do {
                            // Ensure userManager.getUser(id:) exists and returns User
                            let user = try await userManager.getUser(id: workoutFS.userID)
                            return WorkoutFeedItem(user: user, workout: workoutFS)
                        } catch {
                            print("❌ Error fetching user \(workoutFS.userID): \(error)")
                            return nil // Return nil on error fetching a specific user
                        }
                    }
                }
                
                // Collect results from the group
                for try await item in group {
                    if let validItem = item {
                        items.append(validItem)
                    }
                }
            }
            
            // 3. Sort the results (e.g., by date) and update the state on the Main Actor
            // Sort descending to show newest first
            let sortedItems = items.sorted { $0.workout.date.dateValue() > $1.workout.date.dateValue() }
            
            await MainActor.run {
                self.workoutFeedItems = sortedItems
            }
            
        } catch {
            alertController.present(error: error)
        }
    }
}
// MARK: - Preview
#Preview {
    FeedView()
    // Optionally inject a UserManager with mock data for preview
}
