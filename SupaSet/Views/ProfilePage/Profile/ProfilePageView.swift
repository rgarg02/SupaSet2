//
//  ProfilePageView.swift
//  SupaSet
//
//  Created by Rishi Garg on 4/2/25.
//

import SwiftUI
import SwiftData

struct ProfilePageView: View {
    // Environment Objects
    // @Environment(AuthenticationViewModel.self) private var authViewModel // Assuming this is for sign out only now
    @Environment(\.modelContext) private var modelContext
    @Environment(UserManager.self) private var userManager
    @Environment(\.alertController) private var alertController
    @Environment(AuthenticationViewModel.self) private var authViewModel
    // State for sheet presentations
    @State private var showSettingsSheet = false
    @State private var showingEditProfile = false

    // Computed properties for stats (remain the same)
    private var workoutCount: Int { fetchWorkoutCount() }
    private var totalHours: Int { fetchTotalHours() }
    private var weeklyStreak: Int { calculateWeeklyStreak() }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    ProfileHeaderView()
                    ProfileStatsView(
                        workoutCount: workoutCount,
                        totalHours: totalHours,
                        weeklyStreak: weeklyStreak
                    )
                    ProfileMenuView()

                    Spacer(minLength: 20)

                    // Assuming ProfileSignOutButton only needs authViewModel or similar
                    // If it needs user data, pass `user` state
                    ProfileSignOutButton(signOutAction: performSignOut)

                    Spacer()
                }
                .padding(.bottom, 55)
                .padding()
            }
            .background(MeshGradientBackground().ignoresSafeArea())
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSettingsSheet = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.accentColor)
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Edit") { // Changed text to just "Edit"
                        // Ensure user data is loaded before allowing edit? Optional check.
                        guard userManager.user != nil else {
                            // Optionally show an alert or just don't present
                             print("User data not loaded yet, cannot edit.")
                             return
                         }
                        showingEditProfile = true
                    }
                    .foregroundColor(.accentColor)
                    // Disable edit button if user data hasn't loaded yet
                    .disabled(userManager.user == nil)
                }
            }
            // Edit Profile Sheet
            .sheet(
                isPresented: $showingEditProfile
            ) {
                EditProfileView(currentUser: Binding(get: {
                    userManager.user
                }, set: { newUser in
                    userManager.user = newUser
                }))

            }
            // Settings Sheet
            .sheet(isPresented: $showSettingsSheet) {
                SettingsView() // Pass environments if needed
            }
        }
    }

    // fetchWorkoutCount, fetchTotalHours, calculateWeeklyStreak remain the same
     private func fetchWorkoutCount() -> Int {
         let descriptor = FetchDescriptor<Workout>(predicate: #Predicate { $0.isFinished == true })
         return (try? modelContext.fetchCount(descriptor)) ?? 0
     }

     private func fetchTotalHours() -> Int {
         let descriptor = FetchDescriptor<Workout>(predicate: #Predicate { $0.isFinished == true })
         guard let workouts = try? modelContext.fetch(descriptor) else { return 0 }
         let totalSeconds = workouts.reduce(0.0) { $0 + $1.duration }
         return Int((totalSeconds / 3600).rounded())
     }

     private func calculateWeeklyStreak() -> Int {
         // ... (streak calculation logic remains the same) ...
        let descriptor = FetchDescriptor<Workout>(
            predicate: #Predicate { $0.isFinished == true },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        guard let workouts = try? modelContext.fetch(descriptor), !workouts.isEmpty else { return 0 }

        let calendar = Calendar.current
        let currentDate = Date()
        let currentWeekComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate)

        guard let currentWeekStart = calendar.date(from: currentWeekComponents) else { return 0 }
        let lastWeekStart = calendar.date(byAdding: .weekOfYear, value: -1, to: currentWeekStart)!

        var workoutWeeks = Set<Date>()
        for workout in workouts {
            let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: workout.date)
            if let weekStart = calendar.date(from: components) {
                workoutWeeks.insert(weekStart)
            }
        }

        guard workoutWeeks.contains(currentWeekStart) || workoutWeeks.contains(lastWeekStart) else {
            return 0
        }

        var streak = 0
        var weekToCheck = currentWeekStart

        if !workoutWeeks.contains(currentWeekStart) {
            weekToCheck = lastWeekStart
        }

        while workoutWeeks.contains(weekToCheck) {
            streak += 1
            guard let previousWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: weekToCheck) else { break }
            weekToCheck = previousWeek
        }
        return streak
     }


    // MARK: - Actions

    private func performSignOut() {
        // Sign out logic needs AuthenticationViewModel or similar mechanism
        // This example assumes you have a way to trigger sign out.
        print("Attempting sign out...")
        Task { // Perform sign out and data clearing in background task
            do {
                // Example: Assuming authViewModel handles actual sign out
                // try await authViewModel.signOut() // Replace with your actual sign out call
                
                // Clear local SwiftData
                print("Clearing local SwiftData...")
                // Use a background context potentially? For now, main actor is okay.
                try modelContext.delete(model: Workout.self)
                // ... delete other models ...
                try modelContext.save()
                print("Local data cleared.")
                userManager.user = nil
                try? authViewModel.signOut()
                
            } catch {
                print("❌ Error during sign out or data clearing: \(error)")
                alertController.present(error: error)
            }
        }
    }
}
