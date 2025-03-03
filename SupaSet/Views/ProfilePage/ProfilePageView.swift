import SwiftUI

struct ProfilePageView: View {
    @Environment(AuthenticationViewModel.self) private var authViewModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.alertController) private var alertController
    @State private var showSignOutAlert = false
    @State private var showSettingsSheet = false
    @State private var signOutError: Error?
    
    var body: some View {
        NavigationStack {
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
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color("PrimaryThemeColorTwo"))
                .shadow(radius: 2)
        )
    }
    
    private var statsSection: some View {
        HStack(spacing: 20) {
            StatCard(title: "Workouts", value: "0", icon: "dumbbell.fill")
            StatCard(title: "Hours", value: "0", icon: "clock.fill")
            StatCard(title: "Streak", value: "0", icon: "flame.fill")
        }
        .foregroundColor(Color("TextColor"))
    }
    
    private var menuSection: some View {
        VStack(spacing: 8) {
            MenuLink(title: "Your Workouts", icon: "list.bullet", destination: AnyView(Text("Workouts")))
            MenuLink(title: "Progress", icon: "chart.bar.xaxis", destination: WorkoutStatsView())
            MenuLink(title: "Goals", icon: "target", destination: AnyView(Text("Goals")))
            MenuLink(title: "Help & Support", icon: "questionmark.circle", destination: AnyView(Text("Help")))
        }
        .foregroundColor(Color("TextColor"))
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
