import SwiftUI
import SwiftData

struct WorkoutHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Workout>{$0.isFinished == true},sort: \Workout.date, order: .reverse) private var workouts: [Workout]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Stats Card
                    workoutStatsCard
                    
                    // Workout History List
                    ForEach(workouts) { workout in
                        WorkoutHistoryCard(workout: workout)
                    }
                }
                .padding(.bottom, 55)
                .padding()
            }
            .background(
                MeshGradientBackground()
                    .ignoresSafeArea()
            )
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.theme.background)
        }
    }
    // Stats Card View
    private var workoutStatsCard: some View {
        VStack(spacing: 16) {
            Text("Workout Statistics")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 20) {
                StatBox(
                    title: "Total Workouts",
                    value: "\(workouts.count)",
                    icon: "dumbbell.fill"
                )
                
                StatBox(
                    title: "This Month",
                    value: "\(workoutsThisMonth)",
                    icon: "calendar"
                )
                
                StatBox(
                    title: "Avg Duration",
                    value: averageWorkoutDuration,
                    icon: "clock.fill"
                )
            }
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(12)
    }
    
    // Computed Properties
    private var workoutsThisMonth: Int {
        let calendar = Calendar.current
        let now = Date()
        return workouts.filter {
            calendar.isDate($0.date, equalTo: now, toGranularity: .month)
        }.count
    }
    
    private var averageWorkoutDuration: String {
        guard !workouts.isEmpty else { return "0m" }
        let totalDuration = workouts.reduce(0.0) { $0 + $1.duration }
        let averageMinutes = Int(totalDuration / 60.0 / Double(workouts.count))
        return "\(averageMinutes)m"
    }
}



#Preview {
    let preview = PreviewContainer.preview
    WorkoutHistoryView()
        .modelContainer(preview.container)
        .environment(preview.viewModel)
}
