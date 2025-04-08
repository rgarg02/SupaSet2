import SwiftUI
import SwiftData
import Charts
extension ExerciseStatView.ExerciseDataPoint: DateBasedChartPoint {}
struct ExerciseStatView: View {
    @Query var exercises: [SupaSetSchemaV1.WorkoutExercise]
    @Environment(ExerciseViewModel.self) private var exerciseViewModel
    @StateObject private var animationController = ChartAnimationController()
    @State private var selectedPeriod: StatsPeriod = .threeMonths
    @State private var rawSelectedDateVolume: Date?
    @State private var rawSelectedDateWeight: Date?
    
    var selectedDateVolume: Date? {
        guard let rawSelectedDateVolume = rawSelectedDateVolume, !exerciseData.isEmpty else {
            return nil
        }
        // Find the closest data point to the selected date
        return exerciseData.min(by: { abs($0.date.timeIntervalSince(rawSelectedDateVolume)) < abs($1.date.timeIntervalSince(rawSelectedDateVolume)) })?.date
    }
    var selectedDateWeight: Date? {
        guard let rawSelectedDateWeight = rawSelectedDateWeight, !exerciseData.isEmpty else {
            return nil
        }
        // Find the closest data point to the selected date
        return exerciseData.min(by: { abs($0.date.timeIntervalSince(rawSelectedDateWeight)) < abs($1.date.timeIntervalSince(rawSelectedDateWeight)) })?.date
    }
    let exerciseID: String
    
    init(exerciseID: String) {
        self.exerciseID = exerciseID
        // Query to filter WorkoutExercise by exerciseID and sort by workout date
        _exercises = Query(
            filter: #Predicate<SupaSetSchemaV1.WorkoutExercise> {
                $0.exerciseID == exerciseID && $0.workout?.isFinished == true
            },
            sort: [
                SortDescriptor(\SupaSetSchemaV1.WorkoutExercise.workout?.date, order: .forward)
            ]
        )
    }
    
    // Data point for chart and statistics
    struct ExerciseDataPoint: Identifiable {
        let id = UUID()
        let date: Date
        let weight: Double
        let reps: Int
        let totalVolume: Double
        let setCount: Int
        
        var estimatedOneRM: Double {
            // Brzycki formula: weight × (36 / (37 - reps))
            weight * (36.0 / (37.0 - Double(min(reps, 36))))
        }
    }
    
    // Processed exercise data for the chart
    private var exerciseData: [ExerciseDataPoint] {
        // Get the cutoff date based on selected time range
        if let daysBack = selectedPeriod.daysBack {
            let cutoffDate = Calendar.current.date(byAdding: .day, value: -daysBack, to: Date()) ?? Date()
            return exercises
                .compactMap { exercise in
                    // Ensure the workout exists and is after the cutoff date
                    guard let workout = exercise.workout,
                          workout.date >= cutoffDate else {
                        return nil
                    }
                    
                    // Find the best working set (highest weight × reps)
                    let workingSets = exercise.sets.filter { $0.type == .working }
                    guard let bestSet = workingSets.max(by: {
                        $0.weight * Double($0.reps) < $1.weight * Double($1.reps)
                    }) else {
                        return nil
                    }
                    
                    return ExerciseDataPoint(
                        date: workout.date,
                        weight: bestSet.weight,
                        reps: bestSet.reps,
                        totalVolume: exercise.totalVolume,
                        setCount: workingSets.count
                    )
                }
                .sorted(by: { $0.date < $1.date })
        } else {
            return exercises
                .compactMap { exercise in
                    // Ensure the workout exists
                    guard let workout = exercise.workout else {
                        return nil
                    }
                    
                    // Find the best working set (highest weight × reps)
                    let workingSets = exercise.sets.filter { $0.type == .working }
                    guard let bestSet = workingSets.max(by: {
                        $0.weight * Double($0.reps) < $1.weight * Double($1.reps)
                    }) else {
                        return nil
                    }
                    
                    return ExerciseDataPoint(
                        date: workout.date,
                        weight: bestSet.weight,
                        reps: bestSet.reps,
                        totalVolume: exercise.totalVolume,
                        setCount: workingSets.count
                    )
                }
                .sorted(by: { $0.date < $1.date })
        }
    }
    
    // Calculate progress statistics
    private var progressStats: (improvement: Double, percentage: Double) {
        guard let firstWorkout = exerciseData.first, let lastWorkout = exerciseData.last else {
            return (0, 0)
        }
        
        let improvement = lastWorkout.weight - firstWorkout.weight
        let percentage = firstWorkout.weight > 0 ? (improvement / firstWorkout.weight) * 100 : 0
        
        return (improvement, percentage)
    }
    
    // Personal records
    private var personalRecords: (weight: ExerciseDataPoint?, volume: ExerciseDataPoint?, oneRM: ExerciseDataPoint?) {
        let maxWeight = exerciseData.max(by: { $0.weight < $1.weight })
        let maxVolume = exerciseData.max(by: { $0.totalVolume < $1.totalVolume })
        let maxOneRM = exerciseData.max(by: { $0.estimatedOneRM < $1.estimatedOneRM })
        
        return (maxWeight, maxVolume, maxOneRM)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Exercise header with name and muscles
                exerciseHeader
                
                // Time range selector
                PeriodPicker(selectedPeriod: $selectedPeriod)
                
                if exerciseData.isEmpty {
                    emptyStateView
                } else {
                    // Stats overview
                    statsOverview
                    
                    // Progress charts
                    weightProgressChartView
                    
                    // Volume chart
                    volumeProgressChartView
                    
                    // Personal records
                    personalRecordsSection
                    
                    // Recent workouts
                    recentWorkoutsSection
                }
            }
            .padding()
        }
        .navigationTitle("Exercise Stats")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - UI Components
    
    private var exerciseHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Exercise name
            Text(exerciseViewModel.getExerciseName(for: exerciseID))
                .font(.title2)
                .fontWeight(.bold)
            
            // Muscle groups if available
            if let exercise = exerciseViewModel.exercises.first(where: { $0.id == exerciseID }) {
                HStack(spacing: 8) {
                    // Primary muscles
                    if !exercise.primaryMuscles.isEmpty {
                        Text(exercise.primaryMuscles.map { $0.rawValue.capitalized }.joined(separator: ", "))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Equipment if available
                    if let equipment = exercise.equipment, equipment != .none {
                        HStack(spacing: 4) {
                            equipment.image
                                .foregroundColor(.primary.opacity(0.6))
                            Text(equipment.rawValue.capitalized)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var emptyStateView: some View {
        ContentUnavailableView("No progress data available", systemImage: "chart.line.uptrend.xyaxis", description: Text("Complete workouts with this exercise to track your progress"))
    }
    
    private var statsOverview: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("Progress Overview")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                
                // Workout count badge
                Text("\(exerciseData.count) workouts")
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.blue.opacity(0.2))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
            }
            
            // Stats grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                // Weight stat
                if let firstWorkout = exerciseData.first, let lastWorkout = exerciseData.last {
                    StatCard(
                        title: "Current Weight",
                        value: "\(lastWorkout.weight) Lbs",
                        icon: "dumbbell.fill",
                        delay: 0.0,
                        subtitle: "Started at \(Int(firstWorkout.weight)) Lbs",
                        trend: lastWorkout.weight - firstWorkout.weight,
                        trendSuffix: "Lbs"
                    )
                }
                
                // Volume stat
                if let firstWorkout = exerciseData.first, let lastWorkout = exerciseData.last {
                    StatCard(
                        title: "Total Volume",
                        value: "\(lastWorkout.totalVolume) Lbs",
                        icon: "chart.bar.fill",
                        delay: 0.2,
                        subtitle: "Started at \(Int(firstWorkout.totalVolume)) Lbs",
                        trend: lastWorkout.totalVolume - firstWorkout.totalVolume,
                        trendSuffix: "Lbs"
                    )
                }
                
                // One Rep Max stat
                if let firstWorkout = exerciseData.first, let lastWorkout = exerciseData.last {
                    StatCard(
                        title: "Estimated 1RM",
                        value: "\(String(format: "%0.1f", lastWorkout.estimatedOneRM)) Lbs",
                        icon: "figure.strengthtraining.traditional",
                        delay: 0.3,
                        subtitle: "Started at \(Int(firstWorkout.estimatedOneRM)) Lbs",
                        trend: lastWorkout.estimatedOneRM - firstWorkout.estimatedOneRM,
                        trendSuffix: "Lbs"
                    )
                }
                
                // Workout frequency
                if exerciseData.count > 1 {
                    let frequency = calculateWorkoutFrequency()
                    StatCard(
                        title: "Workout Frequency",
                        value: frequency,
                        icon: "calendar.badge.clock",
                        delay: 0.4
                    )
                }
            }
        }
    }
    
    private var weightProgressChartView: some View {
        // Create selection manager for weight chart
        let selectionManager = ChartSelectionManager(dataPoints: exerciseData)
        
        // Create date domain if we have data
        let dateDomain: ClosedRange<Date>? = exerciseData.count > 1 ?
        (exerciseData.first?.date ?? Date())...(exerciseData.last?.date ?? Date()) : nil
        
        return WorkoutProgressChart(
                    dataPoints: exerciseData,
                    yValueProvider: { Double($0.weight) },
                    yAxisLabel: "Weight",
                    dateDomain: dateDomain,
                    period: selectedPeriod,
                    rawSelectedDate: $rawSelectedDateWeight,
                    selectedDateProvider: { selectionManager.findClosestDate(to: $0) },
                    lineColor: .blue,
                    showDaily: true
                )
    }
    
    private var volumeProgressChartView: some View {
        // Create selection manager for volume chart
        let selectionManager = ChartSelectionManager(dataPoints: exerciseData)
        
        // Create date domain if we have data
        let dateDomain: ClosedRange<Date>? = exerciseData.count > 1 ?
        (exerciseData.first?.date ?? Date())...(exerciseData.last?.date ?? Date()) : nil
        
        return WorkoutProgressChart(
            dataPoints: exerciseData,
            yValueProvider: { Double($0.totalVolume) },
            yAxisLabel: "Volume",
            dateDomain: dateDomain,
            period: selectedPeriod,
            rawSelectedDate: $rawSelectedDateVolume,
            selectedDateProvider: { selectionManager.findClosestDate(to: $0) },
            lineColor: .blue,
            showDaily: true
        )
        
    }
    private var personalRecordsSection: some View {
        let records = personalRecords
        
        return VStack(alignment: .leading, spacing: 16) {
            Text("Personal Records")
                .font(.title2)
                .fontWeight(.bold)
            
            // PR Cards
            VStack(spacing: 12) {
                if let weightPR = records.weight {
                    RecordCard(
                        title: "Weight PR",
                        value: "\(Int(weightPR.weight)) Lbs × \(weightPR.reps) reps",
                        date: weightPR.date,
                        iconName: "trophy.fill",
                        color: .yellow
                    )
                }
                
                if let volumePR = records.volume {
                    RecordCard(
                        title: "Volume PR",
                        value: "\(Int(volumePR.totalVolume)) Lbs",
                        date: volumePR.date,
                        iconName: "chart.bar.fill",
                        color: .orange
                    )
                }
                
                if let oneRMPR = records.oneRM {
                    RecordCard(
                        title: "Estimated 1RM PR",
                        value: "\(Int(oneRMPR.estimatedOneRM)) Lbs",
                        date: oneRMPR.date,
                        iconName: "figure.strengthtraining.traditional",
                        color: .purple
                    )
                }
            }
        }
        
    }
    
    private var recentWorkoutsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Workouts")
                .font(.title2)
                .fontWeight(.bold)
            
            // Recent workouts list
            VStack(spacing: 12) {
                ForEach(exerciseData.suffix(3).reversed(), id: \.id) { dataPoint in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(dataPoint.date, style: .date)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text("\(dataPoint.setCount) sets")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Top Set")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("\(Int(dataPoint.weight)) Lbs × \(dataPoint.reps)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        
                        Divider()
                            .frame(height: 30)
                            .padding(.horizontal, 8)
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Volume")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("\(Int(dataPoint.totalVolume)) Lbs")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    }
                    .padding(.bottom)
    
                }
            }
        }
        
    }
    
    // MARK: - Helper Methods
    // Helper function to compute the displayed volume.
    // If the toggle is enabled for longer time ranges, return the average volume.
    private func computedVolume(for data: ExerciseDataPoint) -> Double {
        if (selectedPeriod == .threeMonths || selectedPeriod == .year || selectedPeriod == .allTime) {
            return data.totalVolume
        } else {
            return data.totalVolume
        }
    }
    private func calculateWorkoutFrequency() -> String {
        guard let firstDate = exerciseData.first?.date,
              let lastDate = exerciseData.last?.date else {
            return "N/A"
        }
        
        let totalDays = Calendar.current.dateComponents([.day], from: firstDate, to: lastDate).day ?? 0
        guard totalDays > 0 else { return "N/A" }
        
        let workoutsPerWeek = (Double(exerciseData.count) / Double(totalDays)) * 7
        
        if workoutsPerWeek < 1 {
            // Convert to per month if less than once per week
            let workoutsPerMonth = workoutsPerWeek * 4.33
            return String(format: "%.1f/month", workoutsPerMonth)
        } else {
            return String(format: "%.1f/week", workoutsPerWeek)
        }
    }
}

// MARK: - Supporting Views

struct RecordCard: View {
    let title: String
    let value: String
    let date: Date
    let iconName: String
    let color: Color
    
    var body: some View {
        HStack {
            // PR Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: iconName)
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(value)
                    .font(.headline)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("Achieved")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(date, style: .date)
                    .font(.caption)
                    .fontWeight(.medium)
            }
        }
    }
}
