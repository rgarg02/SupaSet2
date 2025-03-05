import SwiftUI
import SwiftData
import Charts

struct WorkoutStatsSection: View {
    let selectedPeriod: StatsPeriod
    @Environment(ExerciseViewModel.self) private var exerciseViewModel
    @Query private var workouts: [Workout]
    
    // Task cancellation and state variables for async calculations
    @State private var calculationTask: Task<Void, Never>? = nil
    @State private var isLoading = true
    @State private var frequency = "0/week"
    @State private var totalWorkoutCount = 0
    @State private var totalVolumeAmount = 0.0
    @State private var avgDuration: TimeInterval = 0
    @State private var volumeChartDataPoints: [VolumeData] = []
    @State private var muscleGroupDataPoints: [MuscleGroupData] = []
    @State private var topExercisesList: [(exerciseID: String, name: String, weight: Double)] = []
    @State private var yearOffset = 0 // For year navigation

    init(selectedPeriod: StatsPeriod) {
        self.selectedPeriod = selectedPeriod
        if let daysBack = selectedPeriod.daysBack {
            let cutoffDate = Calendar.current.date(byAdding: .day, value: -daysBack, to: Date()) ?? Date()
            self._workouts = Query(filter: #Predicate<Workout> { $0.date >= cutoffDate && $0.isFinished == true })
        } else {
            self._workouts = Query(filter: #Predicate<Workout> { $0.isFinished == true })
        }
    }
    
    // MARK: - Computed Properties
    
    private var hasMultipleYears: Bool {
        guard let firstDate = workouts.map({ $0.date }).min() else { return false }
        let years = Calendar.current.dateComponents([.year], from: firstDate, to: Date()).year ?? 0
        return years > 0
    }
    
    private var yearLabel: String {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: calendar.date(byAdding: .year, value: yearOffset, to: Date())!)
        return "\(year)"
    }
    
    private var chartXDomain: ClosedRange<Date> {
        let calendar = Calendar.current
        let latestWorkoutDate = workouts.map({ $0.date }).max() ?? Date()
        let startDate: Date
        let endDate: Date = latestWorkoutDate
        switch selectedPeriod {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: endDate))!
        case .month:
            startDate = calendar.date(byAdding: .day, value: -29, to: calendar.startOfDay(for: endDate))!
        case .threeMonths:
            startDate = calendar.date(byAdding: .day, value: -89, to: calendar.startOfDay(for: endDate))!
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: endDate)!
        case .allTime:
            startDate = workouts.map({ $0.date }).min() ?? endDate
        }
        return startDate...endDate
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                if isLoading {
                    loadingView
                } else {
                    overviewStatsSection
                    VolumeChartSection(
                        dataPoints: volumeChartDataPoints,
                        dateDomain: chartXDomain,
                        selectedPeriod: selectedPeriod
                    )
                    MuscleGroupChartSection(dataPoints: muscleGroupDataPoints)
                    TopExerciseSection(topExercisesList: topExercisesList)
                    CalendarHeatmap(workouts: workouts, selectedPeriod: selectedPeriod)
                }
            }
        }
        .onAppear { performCalculations() }
        .onChange(of: workouts) { _, _ in performCalculations() }
        .onChange(of: selectedPeriod) { _, _ in
            yearOffset = 0
            isLoading = true
            volumeChartDataPoints = [] // Clear previous data
            performCalculations()
        }
        .onChange(of: yearOffset) {
            Task { await updateVolumeChartForYearChange() }
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
    
    // MARK: - Async Calculations
    
    private func performCalculations() {
        calculationTask?.cancel()
        calculationTask = Task {
            try? await Task.sleep(nanoseconds: 100_000_000)
            if Task.isCancelled { return }
            
            // Cache sorted workouts for chart data so we don't sort multiple times.
            let sortedWorkouts = workouts.sorted { $0.date < $1.date }
            
            // Launch several calculations concurrently with async let.
            async let freqResult: () = calculateFrequencyAsync()
            async let basicStatsResult: () = calculateBasicStatsAsync()
            async let volumeChartResult: () = calculateVolumeChartDataAsync(using: sortedWorkouts)
            async let exerciseStatsResult: () = calculateExerciseStatsAsync()
            
            // Wait for all concurrently
            _ = await (freqResult, basicStatsResult, volumeChartResult, exerciseStatsResult)
            
            if !Task.isCancelled {
                await MainActor.run { isLoading = false }
            }
        }
    }
    
    // Calculate workout frequency
    private func calculateFrequencyAsync() async {
        guard !workouts.isEmpty else {
            await MainActor.run { frequency = "0/week" }
            return
        }
        let result: String
        if selectedPeriod == .allTime {
            let firstWorkoutDate = workouts.map { $0.date }.min() ?? Date()
            let totalWeeks = max(1, (Date().timeIntervalSince(firstWorkoutDate) / (86400 * 7)).rounded())
            let workoutsPerWeek = Double(workouts.count) / totalWeeks
            result = String(format: "%.1f/week", workoutsPerWeek)
        } else {
            let period: Double
            switch selectedPeriod {
            case .week: period = 1
            case .month: period = 4.3
            case .threeMonths: period = 13
            case .year: period = 52
            case .allTime: period = 1
            }
            let workoutsPerWeek = Double(workouts.count) / period
            result = String(format: "%.1f/week", workoutsPerWeek)
        }
        await MainActor.run { frequency = result }
    }
    
    // Calculate basic stats: count, total volume, and average duration
    private func calculateBasicStatsAsync() async {
        let count = workouts.count
        var volumeSum = 0.0
        var durationSum = 0.0
        
        for workout in workouts {
            volumeSum += workout.totalVolume
            durationSum += workout.duration
        }
        let avgDur = count > 0 ? durationSum / Double(count) : 0
        await MainActor.run {
            totalWorkoutCount = count
            totalVolumeAmount = volumeSum
            avgDuration = avgDur
        }
    }
    
    // Calculate chart data based on selected period
    private func calculateVolumeChartDataAsync(using sortedWorkouts: [Workout]) async {
        if Task.isCancelled { return }
        let dateRange = chartXDomain
        let data: [VolumeData]
        
        switch selectedPeriod {
        case .week, .month:
            data = generateDailyDataPoints(from: sortedWorkouts, in: dateRange)
        case .threeMonths:
            data = generateWeeklyDataPoints(from: sortedWorkouts, in: dateRange)
        case .year, .allTime:
            data = generateMonthlyDataPoints(from: sortedWorkouts, in: dateRange)
        }
        if !Task.isCancelled {
            await MainActor.run { volumeChartDataPoints = data }
        }
    }
    
    // Combines calculations for muscle group and top exercise stats into a single pass.
    private func calculateExerciseStatsAsync() async {
        var volumeByMuscle: [String: Double] = [:]
        var exerciseVolume: [(id: String, name: String, volume: Double)] = []
        
        for workout in workouts {
            for exercise in workout.exercises {
                // Get exercise name from view model
                let exerciseName = exerciseViewModel.getExerciseName(for: exercise.exerciseID)
                
                // Check if this exercise is already in our array
                if let index = exerciseVolume.firstIndex(where: { $0.id == exercise.exerciseID }) {
                    // Update existing entry
                    exerciseVolume[index].volume += exercise.totalVolume
                } else {
                    // Add new entry with ID, name and volume
                    exerciseVolume.append((id: exercise.exerciseID, name: exerciseName, volume: exercise.totalVolume))
                }
                
                // Muscle Group: accumulate volume for primary and secondary muscles.
                if let actualExercise = exerciseViewModel.exercises.first(where: { $0.id == exercise.exerciseID }) {
                    for muscle in actualExercise.primaryMuscles {
                        volumeByMuscle[muscle.rawValue, default: 0] += exercise.totalVolume
                    }
                    for muscle in actualExercise.secondaryMuscles {
                        volumeByMuscle[muscle.rawValue, default: 0] += exercise.totalVolume * 0.5
                    }
                }
            }
        }
        
        let topMuscles = volumeByMuscle.map { MuscleGroupData(muscleGroup: $0.key.capitalized, totalVolume: $0.value) }
            .sorted { $0.totalVolume > $1.totalVolume }
            .prefix(5)
            .map { $0 }
        
        let topExercises = exerciseVolume
            .sorted { $0.volume > $1.volume }
            .prefix(5)
            .map { (exerciseID: $0.id, name: $0.name, weight: $0.volume) }
        
        await MainActor.run {
            muscleGroupDataPoints = topMuscles
            topExercisesList = topExercises
        }
    }
    
    private func updateVolumeChartForYearChange() async {
        let dateRange = chartXDomain
        let sortedWorkouts = workouts.sorted { $0.date < $1.date }
        let data = generateMonthlyDataPoints(from: sortedWorkouts, in: dateRange)
        await MainActor.run { volumeChartDataPoints = data }
    }
    
    // MARK: - Data Generation Helpers
            
    private func generateDailyDataPoints(from workouts: [Workout], in dateRange: ClosedRange<Date>) -> [VolumeData] {
        let calendar = Calendar.current
        let filteredWorkouts = workouts.filter { dateRange.contains($0.date) }
        let workoutsByDay = Dictionary(grouping: filteredWorkouts) { calendar.startOfDay(for: $0.date) }
        
        return workoutsByDay.compactMap { date, dayWorkouts in
            let totalVolume = dayWorkouts.reduce(0) { $0 + $1.totalVolume }
            // Skip data points with zero volume
            guard totalVolume > 0 else { return nil }
            return VolumeData(date: date, totalVolume: totalVolume)
        }.sorted { $0.date < $1.date }
    }

    private func generateWeeklyDataPoints(from workouts: [Workout], in dateRange: ClosedRange<Date>) -> [VolumeData] {
        let calendar = Calendar.current
        let filteredWorkouts = workouts.filter { dateRange.contains($0.date) }
        let workoutsByWeek = Dictionary(grouping: filteredWorkouts) {
            calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: $0.date)) ?? $0.date
        }
        
        return workoutsByWeek.compactMap { weekStart, weekWorkouts in
            let totalVolume = weekWorkouts.reduce(0) { $0 + $1.totalVolume }
            let count = weekWorkouts.count
            // Skip data points with zero volume
            guard totalVolume > 0 else { return nil }
            return VolumeData(date: weekStart, totalVolume: totalVolume, workoutCount: count)
        }.sorted { $0.date < $1.date }
    }

    private func generateMonthlyDataPoints(from workouts: [Workout], in dateRange: ClosedRange<Date>) -> [VolumeData] {
        let calendar = Calendar.current
        let filteredWorkouts = workouts.filter { dateRange.contains($0.date) }
        let workoutsByMonth = Dictionary(grouping: filteredWorkouts) {
            let components = calendar.dateComponents([.year, .month], from: $0.date)
            return calendar.date(from: components) ?? $0.date
        }
        
        return workoutsByMonth.compactMap { monthStart, monthWorkouts in
            let totalVolume = monthWorkouts.reduce(0) { $0 + $1.totalVolume }
            let count = monthWorkouts.count
            // Skip data points with zero volume
            guard totalVolume > 0 else { return nil }
            return VolumeData(date: monthStart, totalVolume: totalVolume, workoutCount: count)
        }.sorted { $0.date < $1.date }
    }

    
    // MARK: - Overview, Top Exercises & Consistency Sections
    
    private var overviewStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Overview")
                .font(.title2)
                .fontWeight(.bold)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                StatCard(title: "Total Workouts", value: "\(totalWorkoutCount)", icon: "figure.strengthtraining.traditional", delay: 0.0)
                StatCard(title: "Total Volume", value: "\(Int(totalVolumeAmount)) kg", icon: "scalemass.fill", delay: 0.2)
                StatCard(title: "Avg. Duration", value: formatDuration(avgDuration), icon: "timer", delay: 0.3)
                StatCard(title: "Workout Freq.", value: frequency, icon: "calendar", delay: 0.4)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    // MARK: - Helper
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        return hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes) min"
    }
}
