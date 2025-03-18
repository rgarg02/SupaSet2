import SwiftUI
import SwiftData

struct ProfilePageView: View {
    @Environment(AuthenticationViewModel.self) private var authViewModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.alertController) private var alertController
    @State private var showSignOutAlert = false
    @State private var showSettingsSheet = false
    @State private var signOutError: Error?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    profileHeader
                    statsSection
                    menuSection
                    signOutButton
                }
                .padding()
                .background(Color("BackgroundColor"))
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettingsSheet = true
                    } label: {
                        Image(systemName: "gear")
                            .foregroundColor(Color("AccentColor"))
                    }
                }
            }
        }
        .sheet(isPresented: $showSettingsSheet) {
            SettingsView()
        }
    }
    
    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Profile Image
            ZStack {
                Circle()
                    .fill(Color("PrimaryThemeColorTwo"))
                    .frame(width: 100, height: 100)
                    .shadow(color: Color("TextColor"), radius: 1)
                
                Text(String(authViewModel.getUserEmail().prefix(1)).uppercased())
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("BackgroundColorOpposite"))
            }
            
            // User Info
            VStack(spacing: 8) {
                Text(authViewModel.getUserEmail())
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("TextColor"))
                
                if let creationDate = authViewModel.getUserCreationDate() {
                    Text("Member since \(formatDate(creationDate))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
    
    private var statsSection: some View {
        HStack(spacing: 20) {
            StatCard(title: "Workouts", value: "\(workoutCount)", icon: "dumbbell.fill", delay: 0.0)
            StatCard(title: "Hours", value: "\(totalHours)", icon: "clock.fill", delay: 0.2)
            StatCard(title: "Streak", value: "\(weeklyStreak) \(weeklyStreak > 1 ? "weeks" : "week")", icon: "flame.fill", delay: 0.3)
        }
        .foregroundColor(Color("TextColor"))
    }
    private var workoutCount: Int {
        let descriptor = FetchDescriptor<Workout>(predicate: #Predicate { $0.isFinished == true })
        return (try? modelContext.fetchCount(descriptor)) ?? 0
    }
    private var totalHours: Int {
        let descriptor = FetchDescriptor<Workout>(predicate: #Predicate { $0.isFinished == true })
        guard let workouts = try? modelContext.fetch(descriptor) else { return 0 }
        
        // Calculate total duration in seconds
        let totalSeconds = workouts.reduce(0.0) { $0 + $1.duration }
        
        // Convert to hours
        return Int((totalSeconds / 3600).rounded())
    }

    private var weeklyStreak: Int {
        let descriptor = FetchDescriptor<Workout>(
            predicate: #Predicate { $0.isFinished == true },
            sortBy: [SortDescriptor(\.date, order: .reverse)] // Sort by most recent first
        )
        guard let workouts = try? modelContext.fetch(descriptor), !workouts.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let currentDate = Date()
        
        // Get current week and threshold for active streak
        let currentWeekComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate)
        let currentWeekStart = calendar.date(from: currentWeekComponents)!
        let lastWeekStart = calendar.date(byAdding: .weekOfYear, value: -1, to: currentWeekStart)!
        
        // Map workouts to their week start dates
        var workoutWeeks = [Date]()
        for workout in workouts {
            let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: workout.date)
            if let weekStart = calendar.date(from: components) {
                workoutWeeks.append(weekStart)
            }
        }
        
        // No workouts in current or last week means no active streak
        if !workoutWeeks.contains(currentWeekStart) && !workoutWeeks.contains(lastWeekStart) {
            return 0
        }
        
        // Determine starting week for the streak
        let streakStartWeek = workoutWeeks.contains(currentWeekStart) ? currentWeekStart : lastWeekStart
        var streak = 1 // Count the current/last week
        var weekToCheck = streakStartWeek
        
        // Check consecutive previous weeks
        while true {
            weekToCheck = calendar.date(byAdding: .weekOfYear, value: -1, to: weekToCheck)!
            if workoutWeeks.contains(weekToCheck) {
                streak += 1
            } else {
                break // Break the loop on first gap
            }
        }
        
        return streak
    }
    private var menuSection: some View {
        VStack(spacing: 8) {
            MenuLink(title: "Progress", icon: "chart.bar.xaxis", destination: WorkoutStatsView())
        }
        .foregroundColor(.text)
    }
    
    private var signOutButton: some View {
        Button {
            let buttons = [
                AlertButton(title: "Sign Out", role: .destructive, action: {
                    performSignOut()
                }),
                AlertButton(.cancel)
            ]
            alertController.present(.alert, title: "Sign Out?", message: "Are you sure you want to sign out?", buttons: buttons)
        } label: {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                Text("Sign Out")
            }
            .foregroundColor(Color("Cancel"))
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color("Cancel").opacity(0.5), lineWidth: 1)
            )
        }
        .padding(.top)
    }
    
    private func performSignOut() {
        do {
            /*Workout.self,
             WorkoutExercise.self,
             ExerciseSet.self,
             ExerciseDetail.self,
             Template.self,
             TemplateExercise.self,
             TemplateExerciseSet.self
             */
            try authViewModel.signOut()
            try modelContext.delete(model: Workout.self)
            try modelContext.delete(model: WorkoutExercise.self)
            try modelContext.delete(model: ExerciseSet.self)
            try modelContext.delete(model: ExerciseDetail.self)
            try modelContext.delete(model: Template.self)
            try modelContext.delete(model: TemplateExercise.self)
            try modelContext.delete(model: TemplateExerciseSet.self)
            try modelContext.delete(model: UserProfile.self)
            
            // reset all models
        } catch {
            alertController.present(error: error)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

#Preview {
    ProfilePageView()
        .environment(AuthenticationViewModel())
}
