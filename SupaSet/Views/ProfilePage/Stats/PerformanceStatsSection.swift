//
//  PerformanceStatsSection.swift
//  SupaSet
//
//  Created by Rishi Garg on 3/3/25.
//


import SwiftUI
import SwiftData
import Charts

struct PerformanceStatsSection: View {
    let selectedPeriod: StatsPeriod
    @Environment(ExerciseViewModel.self) private var exerciseViewModel
    @Query private var workouts: [Workout]
    
    // State variables for calculations
    @State private var isLoading = true
    @State private var strengthProgress: [StrengthProgressData] = []
    @State private var volumeProgressByMuscle: [MuscleVolumeProgressData] = []
    @State private var workoutEfficiency: Double = 0
    @State private var intensityTrend: [IntensityData] = []
    @State private var oneRepMaxEstimates: [(name: String, weight: Double)] = []
    
    init(selectedPeriod: StatsPeriod) {
        self.selectedPeriod = selectedPeriod
        if let daysBack = selectedPeriod.daysBack {
            let cutoffDate = Calendar.current.date(byAdding: .day, value: -daysBack, to: Date()) ?? Date()
            self._workouts = Query(filter: #Predicate<Workout> { $0.date >= cutoffDate && $0.isFinished == true })
        } else {
            self._workouts = Query(filter: #Predicate<Workout> { $0.isFinished == true })
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            if isLoading {
                loadingView
            } else {
                // Strength Progress
                strengthProgressSection
                
                // Estimated One-Rep Max
                oneRepMaxSection
                
                // Volume Progress By Muscle Group
                volumeByMuscleSection
                
                // Workout Intensity Trend
                intensityTrendSection
                
                // Workout Efficiency
                workoutEfficiencySection
            }
        }
        .onAppear { performCalculations() }
        .onChange(of: workouts) { performCalculations() }
        .onChange(of: selectedPeriod) {
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
            Text("Analyzing your performance metrics...")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, minHeight: 300)
    }
    
    // MARK: - UI Sections
    
    private var strengthProgressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Strength Progress")
                .font(.title2)
                .fontWeight(.bold)
            
            if strengthProgress.isEmpty {
                Text("Not enough data to show strength progress")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 200)
            } else {
                Chart {
                    ForEach(strengthProgress) { data in
                        LineMark(
                            x: .value("Date", data.date),
                            y: .value("Weight", data.weight)
                        )
                        .foregroundStyle(by: .value("Exercise", data.exerciseName))
                        .symbol(by: .value("Exercise", data.exerciseName))
                        .interpolationMethod(.catmullRom)
                    }
                }
                .frame(height: 250)
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: .dateTime.month().day())
                    }
                }
                .accessibilityLabel("Strength Progress Chart")
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    private var oneRepMaxSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Estimated One-Rep Max")
                .font(.title2)
                .fontWeight(.bold)
            
            if oneRepMaxEstimates.isEmpty {
                Text("Not enough data to estimate one-rep max")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 100)
            } else {
                ForEach(oneRepMaxEstimates.indices, id: \.self) { index in
                    HStack {
                        Image(systemName: "trophy.fill")
                            .foregroundColor(.yellow)
                        Text(oneRepMaxEstimates[index].name)
                            .font(.callout)
                            .lineLimit(1)
                        Spacer()
                        Text("\(Int(oneRepMaxEstimates[index].weight)) kg")
                            .font(.callout.bold())
                            .foregroundColor(.blue)
                    }
                    .padding(.vertical, 5)
                    if index < oneRepMaxEstimates.count - 1 { Divider() }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    private var volumeByMuscleSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Volume Progress By Muscle")
                .font(.title2)
                .fontWeight(.bold)
            
            if volumeProgressByMuscle.isEmpty {
                Text("Not enough data to show muscle progress")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 200)
            } else {
                Chart {
                    ForEach(volumeProgressByMuscle) { data in
                        LineMark(
                            x: .value("Date", data.date),
                            y: .value("Volume", data.volume)
                        )
                        .foregroundStyle(by: .value("Muscle", data.muscleGroup))
                        .interpolationMethod(.catmullRom)
                    }
                }
                .frame(height: 250)
                .chartLegend(position: .bottom, alignment: .center)
                .accessibilityLabel("Volume Progress By Muscle Chart")
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    private var intensityTrendSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Workout Intensity Trend")
                .font(.title2)
                .fontWeight(.bold)
            
            if intensityTrend.isEmpty {
                Text("Not enough data to show intensity trend")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 200)
            } else {
                Chart {
                    ForEach(intensityTrend) { data in
                        LineMark(
                            x: .value("Date", data.date),
                            y: .value("Intensity", data.intensity)
                        )
                        .foregroundStyle(Color.red.gradient)
                        .interpolationMethod(.catmullRom)
                    }
                    
                    RuleMark(y: .value("Average", intensityTrend.map { $0.intensity }.reduce(0, +) / Double(intensityTrend.count)))
                        .foregroundStyle(Color.gray.opacity(0.5))
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                        .annotation(position: .top, alignment: .trailing) {
                            Text("Average")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                }
                .frame(height: 250)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .accessibilityLabel("Workout Intensity Trend Chart")
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    private var workoutEfficiencySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Workout Efficiency")
                .font(.title2)
                .fontWeight(.bold)
            
            HStack {
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 10)
                        .frame(width: 120, height: 120)
                    
                    Circle()
                        .trim(from: 0, to: min(CGFloat(workoutEfficiency) / 100, 1.0))
                        .stroke(
                            workoutEfficiency > 80 ? Color.green : 
                            workoutEfficiency > 60 ? Color.yellow : Color.red,
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                    
                    VStack {
                        Text("\(Int(workoutEfficiency))%")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Efficiency")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.trailing, 10)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your workout efficiency is calculated based on:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Rest time optimization")
                            .font(.callout)
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Volume per time unit")
                            .font(.callout)
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Exercise selection balance")
                            .font(.callout)
                    }
                }
                .padding(.leading, 10)
            }
            .padding()
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    // MARK: - Calculations
    
    private func performCalculations() {
        Task {
            await calculateStrengthProgress()
            await calculateVolumeProgressByMuscle()
            await calculateWorkoutEfficiency()
            await calculateIntensityTrend()
            await calculateOneRepMaxEstimates()
            await MainActor.run { isLoading = false }
        }
    }
    
    // Implementation of calculation methods
    private func calculateStrengthProgress() async {
        // Get the top 3 most frequent exercises
        let exerciseFrequency = workouts.flatMap { $0.exercises }.reduce(into: [String: Int]()) { counts, exercise in
            counts[exercise.exerciseID, default: 0] += 1
        }
        
        let topExerciseIDs = exerciseFrequency.sorted { $0.value > $1.value }.prefix(3).map { $0.key }
        
        // For each top exercise, find the max weight used in each workout
        var progressData: [StrengthProgressData] = []
        
        for exerciseID in topExerciseIDs {
            let exerciseName = exerciseViewModel.getExerciseName(for: exerciseID)
            
            // Get all workouts with this exercise, sorted by date
            let relevantWorkouts = workouts.filter { workout in
                workout.exercises.contains { $0.exerciseID == exerciseID }
            }.sorted { $0.date < $1.date }
            
            // For each workout, find the max weight used for this exercise
            for workout in relevantWorkouts {
                if let exercise = workout.exercises.first(where: { $0.exerciseID == exerciseID }) {
                    if let maxSet = exercise.sets.filter({ !$0.isWarmupSet }).max(by: { $0.weight < $1.weight }) {
                        progressData.append(StrengthProgressData(
                            date: workout.date,
                            exerciseName: exerciseName,
                            weight: maxSet.weight
                        ))
                    }
                }
            }
        }
        
        await MainActor.run { strengthProgress = progressData }
    }
    
    private func calculateVolumeProgressByMuscle() async {
        // Get the top 3 most trained muscle groups
        var totalVolumeByMuscle: [String: Double] = [:]
        
        for workout in workouts {
            for exercise in workout.exercises {
                if let actualExercise = exerciseViewModel.exercises.first(where: { $0.id == exercise.exerciseID }) {
                    for muscle in actualExercise.primaryMuscles {
                        totalVolumeByMuscle[muscle.rawValue, default: 0] += exercise.totalVolume
                    }
                }
            }
        }
        
        let topMuscles = totalVolumeByMuscle.sorted { $0.value > $1.value }.prefix(3).map { $0.key }
        
        // Group workouts by week
        let calendar = Calendar.current
        let workoutsByWeek = Dictionary(grouping: workouts) { workout in
            let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: workout.date)
            return calendar.date(from: components) ?? workout.date
        }
        
        var progressData: [MuscleVolumeProgressData] = []
        
        for (weekStart, weekWorkouts) in workoutsByWeek.sorted(by: { $0.key < $1.key }) {
            for muscle in topMuscles {
                var weeklyVolume: Double = 0
                
                for workout in weekWorkouts {
                    for exercise in workout.exercises {
                        if let actualExercise = exerciseViewModel.exercises.first(where: { $0.id == exercise.exerciseID }) {
                            if actualExercise.primaryMuscles.map({ $0.rawValue }).contains(muscle) {
                                weeklyVolume += exercise.totalVolume
                            } else if actualExercise.secondaryMuscles.map({ $0.rawValue }).contains(muscle) {
                                weeklyVolume += exercise.totalVolume * 0.5
                            }
                        }
                    }
                }
                
                progressData.append(MuscleVolumeProgressData(
                    date: weekStart,
                    muscleGroup: muscle.capitalized,
                    volume: weeklyVolume
                ))
            }
        }
        
        await MainActor.run { volumeProgressByMuscle = progressData }
    }
    
    private func calculateWorkoutEfficiency() async {
        // This is a complex calculation based on multiple factors
        // For simplicity, we'll use a formula that considers:
        // 1. Workout duration vs volume ratio
        // 2. Consistent workout frequency
        // 3. Exercise selection balance
        
        guard !workouts.isEmpty else {
            await MainActor.run { workoutEfficiency = 0 }
            return
        }
        
        // 1. Volume per minute factor (30% of score)
        let avgVolumePerMinute = workouts.map { $0.totalVolume / (max($0.duration / 60, 1)) }.reduce(0, +) / Double(workouts.count)
        // Normalize to a 0-30 scale (assuming 10kg/min is excellent)
        let volumeEfficiencyScore = min(avgVolumePerMinute / 10 * 30, 30)
        
        // 2. Workout consistency factor (30% of score)
        let workoutDates = workouts.map { $0.date }.sorted()
        var consistencyScore: Double = 30
        if workoutDates.count > 1 {
            var totalDeviation: Double = 0
            for i in 1..<workoutDates.count {
                let interval = workoutDates[i].timeIntervalSince(workoutDates[i-1]) / 86400 // in days
                // Penalize for intervals that deviate from ideal (assume 2 days is ideal)
                totalDeviation += abs(interval - 2)
            }
            let avgDeviation = totalDeviation / Double(workoutDates.count - 1)
            consistencyScore = max(30 - (avgDeviation * 5), 0) // Deduct 5 points per day of deviation
        }
        
        // 3. Exercise balance factor (40% of score)
        var exercisesByMuscleGroup: [String: Int] = [:]
        for workout in workouts {
            for exercise in workout.exercises {
                if let actualExercise = exerciseViewModel.exercises.first(where: { $0.id == exercise.exerciseID }) {
                    for muscle in actualExercise.primaryMuscles {
                        exercisesByMuscleGroup[muscle.rawValue, default: 0] += 1
                    }
                }
            }
        }
        
        // Calculate variance between muscle groups to determine balance
        let muscleValues = exercisesByMuscleGroup.values.map { Double($0) }
        let avgMuscleValue = muscleValues.reduce(0, +) / Double(max(muscleValues.count, 1))
        let variance = muscleValues.map { pow($0 - avgMuscleValue, 2) }.reduce(0, +) / Double(max(muscleValues.count, 1))
        let standardDeviation = sqrt(variance)
        
        // Lower standard deviation means more balanced training
        let balanceScore = max(40 - (standardDeviation * 2), 0)
        
        // Calculate final efficiency score
        let finalScore = volumeEfficiencyScore + consistencyScore + balanceScore
        
        await MainActor.run { workoutEfficiency = min(finalScore, 100) }
    }
    
    private func calculateIntensityTrend() async {
        let sortedWorkouts = workouts.sorted { $0.date < $1.date }
        var intensityData: [IntensityData] = []
        
        for workout in sortedWorkouts {
            // Calculate average weight × reps per exercise as intensity
            var totalIntensity: Double = 0
            var exerciseCount = 0
            
            for exercise in workout.exercises {
                let exerciseIntensity = exercise.sets
                    .filter { !$0.isWarmupSet }
                    .map { $0.weight * Double($0.reps) }
                    .reduce(0, +)
                
                if !exercise.sets.filter({ !$0.isWarmupSet }).isEmpty {
                    totalIntensity += exerciseIntensity
                    exerciseCount += 1
                }
            }
            
            if exerciseCount > 0 {
                let avgIntensity = totalIntensity / Double(exerciseCount)
                intensityData.append(IntensityData(date: workout.date, intensity: avgIntensity))
            }
        }
        
        await MainActor.run { intensityTrend = intensityData }
    }
    
    private func calculateOneRepMaxEstimates() async {
        // Group exercises by exerciseID
        var exerciseSets: [String: [(reps: Int, weight: Double)]] = [:]
        
        for workout in workouts {
            for exercise in workout.exercises {
                let exerciseName = exerciseViewModel.getExerciseName(for: exercise.exerciseID)
                
                // Add all work sets (non-warmup sets with significant weight)
                for set in exercise.sets {
                    if !set.isWarmupSet && set.weight > 0 && set.reps > 0 && set.reps <= 12 {
                        exerciseSets[exerciseName, default: []].append((reps: set.reps, weight: set.weight))
                    }
                }
            }
        }
        
        // Calculate 1RM for each exercise using Brzycki formula: 1RM = weight × (36 / (37 - reps))
        var oneRepMaxes: [(name: String, weight: Double)] = []
        
        for (exerciseName, sets) in exerciseSets {
            // Find the set that would give the highest 1RM estimate
            let maxOneRepMax = sets.map { set in
                // Brzycki formula
                set.weight * (36.0 / (37.0 - Double(set.reps)))
            }.max() ?? 0
            
            if maxOneRepMax > 0 {
                oneRepMaxes.append((name: exerciseName, weight: maxOneRepMax))
            }
        }
        
        // Sort by highest 1RM and take top 5
        let topOneRepMaxes = oneRepMaxes.sorted { $0.weight > $1.weight }.prefix(5)
        
        await MainActor.run { oneRepMaxEstimates = Array(topOneRepMaxes) }
    }
}

// MARK: - Data Models

struct StrengthProgressData: Identifiable {
    let id = UUID()
    let date: Date
    let exerciseName: String
    let weight: Double
}

struct MuscleVolumeProgressData: Identifiable {
    let id = UUID()
    let date: Date
    let muscleGroup: String
    let volume: Double
}

struct IntensityData: Identifiable {
    let id = UUID()
    let date: Date
    let intensity: Double
}
