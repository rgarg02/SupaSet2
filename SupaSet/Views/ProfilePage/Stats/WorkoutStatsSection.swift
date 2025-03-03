//
//  WorkoutStatsSection.swift
//  SupaSet
//
//  Created by Rishi Garg on 3/2/25.
//

import SwiftUI
import SwiftData
import Charts

struct WorkoutStatsSection: View {
    let selectedPeriod: StatsPeriod
    @Environment(ExerciseViewModel.self) private var exerciseViewModel
    @Query private var workouts: [Workout]
    
    // State variables for async calculations
    @State private var isLoading = true
    @State private var frequency = "0/week"
    @State private var totalWorkoutCount = 0
    @State private var totalVolumeAmount = 0.0
    @State private var avgDuration: TimeInterval = 0
    @State private var volumeChartDataPoints: [VolumeData] = []
    @State private var muscleGroupDataPoints: [MuscleGroupData] = []
    @State private var topExercisesList: [(name: String, volume: Double)] = []
    
    init(selectedPeriod: StatsPeriod) {
        self.selectedPeriod = selectedPeriod
        if let daysBack = selectedPeriod.daysBack {
            let cutoffDate = Calendar.current.date(byAdding: .day, value: -daysBack, to: Date()) ?? Date()
            self._workouts = Query(filter: #Predicate<Workout>{$0.date >= cutoffDate && $0.isFinished == true})
        } else {
            self._workouts = Query(filter: #Predicate<Workout>{$0.isFinished == true})
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if isLoading {
                    loadingView
                } else {
                    // Overview Stats
                    overviewStatsSection
                    
                    // Volume Progress Chart
                    volumeChartSection
                    
                    // Muscle Group Distribution
                    muscleGroupSection
                    
                    // Top Exercises
                    topExercisesSection
                    
                    // Workout Consistency
                    workoutConsistencySection
                }
            }
        }
        .onAppear {
            performCalculations()
        }
        .onChange(of: workouts) {
            performCalculations()
        }
        .onChange(of: selectedPeriod) {
            // Reset loading state when period changes
            isLoading = true
            performCalculations()
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 30) {
            ProgressView()
                .scaleEffect(1.5)
                .padding(.top, 40)
            
            Text("Calculating your workout stats...")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, minHeight: 300)
    }
    
    // MARK: - Calculation Methods
    
    private func performCalculations() {
        // Use Task to perform calculations asynchronously
        Task {
            // Small delay to ensure loading indicator shows
            try? await Task.sleep(nanoseconds: 100_000_000)
            
            // Calculate data points on background thread
            await calculateAllStats()
            
            // Update UI on main thread
            await MainActor.run {
                isLoading = false
            }
        }
    }
    
    private func calculateAllStats() async {
        await withTaskGroup(of: Void.self) { group in
            // Add all calculation tasks to the group
            group.addTask { await calculateFrequencyAsync() }
            group.addTask { await calculateBasicStatsAsync() }
            group.addTask { await calculateVolumeChartDataAsync() }
            group.addTask { await calculateMuscleGroupDataAsync() }
            group.addTask { await calculateTopExercisesAsync() }
            
            // Wait for all tasks to complete
            for await _ in group { }
        }
    }
    
    private func calculateFrequencyAsync() async {
        guard !workouts.isEmpty else {
            await MainActor.run { frequency = "0/week" }
            return
        }
        
        let result: String
        
        if selectedPeriod == .allTime {
            // Calculate average per week for all time
            let firstWorkoutDate = workouts.map { $0.date }.min() ?? Date()
            let totalWeeks = max(1, (Date().timeIntervalSince(firstWorkoutDate) / (86400 * 7)).rounded())
            let workoutsPerWeek = Double(workouts.count) / totalWeeks
            
            result = String(format: "%.1f/week", workoutsPerWeek)
        } else {
            // Calculate for selected period
            let period: Double
            switch selectedPeriod {
            case .week: period = 1
            case .month: period = 4.3
            case .threeMonths: period = 13
            case .year: period = 52
            case .allTime: period = 1 // Should not reach here
            }
            
            let workoutsPerWeek = Double(workouts.count) / period
            result = String(format: "%.1f/week", workoutsPerWeek)
        }
        
        await MainActor.run { frequency = result }
    }
    
    private func calculateBasicStatsAsync() async {
        let count = workouts.count
        let volume = workouts.reduce(0) { $0 + $1.totalVolume }
        let duration: TimeInterval
        
        if !workouts.isEmpty {
            let totalDuration = workouts.reduce(0) { $0 + $1.duration }
            duration = totalDuration / Double(count)
        } else {
            duration = 0
        }
        
        await MainActor.run {
            totalWorkoutCount = count
            totalVolumeAmount = volume
            avgDuration = duration
        }
    }
    
    private func calculateVolumeChartDataAsync() async {
        let sortedWorkouts = workouts.sorted(by: { $0.date < $1.date })
        let data = sortedWorkouts.map { VolumeData(date: $0.date, totalVolume: $0.totalVolume) }
        
        await MainActor.run {
            volumeChartDataPoints = data
        }
    }
    
    private func calculateMuscleGroupDataAsync() async {
        // Dictionary to store volume by muscle group
        var volumeByMuscle: [String: Double] = [:]
        
        for workout in workouts {
            for exercise in workout.exercises {
                // Try to find the exercise in the view model
                if let actualExercise = exerciseViewModel.exercises.first(where: { $0.id == exercise.exerciseID }) {
                    // Add volume to primary muscles
                    for muscle in actualExercise.primaryMuscles {
                        let muscleName = muscle.rawValue
                        volumeByMuscle[muscleName, default: 0] += exercise.totalVolume
                    }
                    
                    // Add half volume to secondary muscles
                    for muscle in actualExercise.secondaryMuscles {
                        let muscleName = muscle.rawValue
                        volumeByMuscle[muscleName, default: 0] += exercise.totalVolume * 0.5
                    }
                }
            }
        }
        
        // Convert dictionary to array and sort by volume
        let result = volumeByMuscle.map { MuscleGroupData(muscleGroup: $0.key.capitalized, totalVolume: $0.value) }
            .sorted(by: { $0.totalVolume > $1.totalVolume })
            .prefix(5)
            .map { $0 } // Convert back to array
        
        await MainActor.run {
            muscleGroupDataPoints = result
        }
    }
    
    private func calculateTopExercisesAsync() async {
        var exerciseVolume: [String: Double] = [:]
        
        for workout in workouts {
            for exercise in workout.exercises {
                let exerciseName = exerciseViewModel.getExerciseName(for: exercise.exerciseID)
                exerciseVolume[exerciseName, default: 0] += exercise.totalVolume
            }
        }
        
        let result = exerciseVolume.map { ($0.key, $0.value) }
            .sorted(by: { $0.1 > $1.1 })  // Access tuple elements by index (1 is the volume)
            .prefix(5)
            .map { $0 }
        
        await MainActor.run {
            topExercisesList = result
        }
    }
    
    // MARK: - View Sections
    
    private var overviewStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Overview")
                .font(.title2)
                .fontWeight(.bold)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                StatCard(title: "Total Workouts", value: "\(totalWorkoutCount)", icon: "figure.strengthtraining.traditional")
                
                StatCard(title: "Total Volume", value: "\(Int(totalVolumeAmount)) kg", icon: "scalemass.fill")
                
                StatCard(title: "Avg. Duration", value: formatDuration(avgDuration), icon: "timer")
                
                StatCard(title: "Workout Freq.", value: frequency, icon: "calendar")
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    private var volumeChartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Volume Progress")
                .font(.title2)
                .fontWeight(.bold)
            
            if volumeChartDataPoints.isEmpty {
                Text("No workout data for this period")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 200)
            } else {
                Chart {
                    ForEach(volumeChartDataPoints) { data in
                        LineMark(
                            x: .value("Date", data.date),
                            y: .value("Volume", data.totalVolume)
                        )
                        .foregroundStyle(Color.blue.gradient)
                        .interpolationMethod(.catmullRom)
                        
                        AreaMark(
                            x: .value("Date", data.date),
                            y: .value("Volume", data.totalVolume)
                        )
                        .foregroundStyle(
                            .linearGradient(colors: [.blue.opacity(0.3), .clear], startPoint: .top, endPoint: .bottom)
                        )
                        .interpolationMethod(.catmullRom)
                        
                        PointMark(
                            x: .value("Date", data.date),
                            y: .value("Volume", data.totalVolume)
                        )
                        .foregroundStyle(Color.blue)
                    }
                }
                .frame(height: 200)
                .chartYAxis {
                    AxisMarks()
                }
                .chartXAxis {
                    AxisMarks()
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    private var muscleGroupSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Muscle Focus")
                .font(.title2)
                .fontWeight(.bold)
            
            if muscleGroupDataPoints.isEmpty {
                Text("No muscle data for this period")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 200)
            } else {
                Chart {
                    ForEach(muscleGroupDataPoints) { data in
                        BarMark(
                            x: .value("Volume", data.totalVolume),
                            y: .value("Muscle", data.muscleGroup)
                        )
                        .foregroundStyle(Color.purple.gradient)
                        .cornerRadius(6)
                    }
                }
                .frame(height: 250)
                .chartXAxis {
                    AxisMarks()
                }
                .chartYAxis {
                    AxisMarks()
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    private var topExercisesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Top Exercises")
                .font(.title2)
                .fontWeight(.bold)
            
            if topExercisesList.isEmpty {
                Text("No exercise data for this period")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 100)
            } else {
                ForEach(topExercisesList.indices, id: \.self) { index in
                    HStack {
                        Text("\(index + 1)")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 28, height: 28)
                            .background(Color.blue)
                            .clipShape(Circle())
                        
                        Text(topExercisesList[index].name)
                            .font(.callout)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Text("\(Int(topExercisesList[index].volume)) kg")
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 5)
                    
                    if index < topExercisesList.count - 1 {
                        Divider()
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    private var workoutConsistencySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Workout Commitment")
                .font(.title2)
                .fontWeight(.bold)
            
            CalendarHeatmap(workouts: workouts, selectedPeriod: selectedPeriod)
//                .frame(height: 140)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    // MARK: - Helper Functions
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes) min"
        }
    }
}
