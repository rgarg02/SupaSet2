import SwiftUI
import SwiftData
import Charts

struct PredictionsSection: View {
    @Environment(ExerciseViewModel.self) private var exerciseViewModel
    @Query private var workouts: [SupaSetSchemaV1.Workout]
    let selectedPeriod: StatsPeriod
    
    // Analysis state
    @State private var isLoading = true
    @State private var nextWorkoutSuggestion: WorkoutSuggestion?
    @State private var strengthTrends: [StrengthTrend] = []
    @State private var workoutSchedule: [Int: Double] = [:] // Day of week -> optimal energy level
    @State private var goalTimeline: [GoalPrediction] = []
    @State private var focusRecommendations: [MuscleGroupFocus] = []
    @State private var injuryRiskAreas: [InjuryRiskArea] = []
    
    init(selectedPeriod: StatsPeriod) {
        if let daysBack = selectedPeriod.daysBack {
            let cutoffDate = Calendar.current.date(byAdding: .day, value: -daysBack, to: Date()) ?? Date()
            self._workouts = Query(filter: #Predicate<Workout> { $0.date >= cutoffDate && $0.isFinished == true })
        } else {
            self._workouts = Query(filter: #Predicate<Workout> { $0.isFinished == true })
        }
        self.selectedPeriod = selectedPeriod
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Content based on loading state
                if isLoading {
                    loadingView
                } else if workouts.isEmpty {
                    emptyStateView
                } else {
                    predictionContent
                }
            }
            .padding()
        }
        .navigationTitle("Workout Predictions")
        .background(Color(.systemGroupedBackground))
        .onAppear {
            analyzeWorkoutData()
        }
        .onChange(of: workouts) {
            analyzeWorkoutData()
        }
        .onChange(of: selectedPeriod) {
            isLoading = true
            analyzeWorkoutData()
        }
    }
    
    
    private var loadingView: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.5)
                .padding()
            
            Text("Analyzing your workout history...")
                .foregroundColor(.secondary)
        }
        .frame(height: 200)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "figure.run")
                .font(.system(size: 60))
                .foregroundColor(.blue.opacity(0.7))
                .padding()
            
            Text("No Workout Data")
                .font(.title3)
                .fontWeight(.bold)
            
            Text("Complete some workouts to get personalized predictions.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    private var predictionContent: some View {
        VStack(spacing: 24) {
            // Next workout suggestion
            nextWorkoutView
            
            // Optimal schedule heatmap
            scheduleHeatmapView
            
            // Strength trend prediction
            strengthTrendView
            
            // Goal timeline
            goalTimelineView
            
            // Focus recommendations
            focusRecommendationsView
            
            // Injury risk assessment
            injuryRiskView
        }
    }
    
    private var nextWorkoutView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Next Workout Suggestion")
                .font(.title2)
                .fontWeight(.bold)
            
            if let suggestion = nextWorkoutSuggestion {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "calendar.badge.plus")
                            .font(.title2)
                            .foregroundColor(.blue)
                        
                        Text(suggestion.name)
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Text(formatOptimalDay(suggestion.optimalDay))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    Text("Focus areas based on your training patterns and recovery needs:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Exercise suggestions
                    ForEach(suggestion.exercises, id: \.id) { exercise in
                        HStack(spacing: 12) {
                            Image(systemName: exercise.isPrimary ? "star.fill" : "circle.fill")
                                .foregroundColor(exercise.isPrimary ? .yellow : .gray)
                                .font(.caption)
                            
                            Text(exercise.name)
                                .font(.body)
                            
                            Spacer()
                            
                            Text("\(exercise.sets) sets")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    
                    Divider()
                    
                    // Reason for suggestion
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.yellow)
                        
                        Text(suggestion.reasonText)
                            .font(.callout)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding()
                .background(Color(.tertiarySystemGroupedBackground))
                .cornerRadius(12)
            } else {
                Text("Not enough data to generate workout suggestions")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    private var scheduleHeatmapView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Optimal Workout Schedule")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Based on your performance patterns and recovery cycles")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if workoutSchedule.isEmpty {
                Text("Not enough data to determine optimal schedule")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                VStack(spacing: 10) {
                    // Days of week
                    HStack(spacing: 0) {
                        ForEach(0..<7) { day in
                            Text(formatWeekday(day))
                                .font(.caption)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    
                    // Heatmap cells
                    HStack(spacing: 0) {
                        ForEach(0..<7) { day in
                            let energyLevel = workoutSchedule[day, default: 0]
                            dayHeatmapCell(day: day, energyLevel: energyLevel)
                        }
                    }
                    .frame(height: 70)
                    
                    // Legend
                    HStack {
                        Text("Low Energy")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Rectangle()
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [.gray.opacity(0.3), .green, .blue]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(height: 8)
                        
                        Text("High Energy")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 8)
                }
                .padding()
                .background(Color(.tertiarySystemGroupedBackground))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    private func dayHeatmapCell(day: Int, energyLevel: Double) -> some View {
        VStack {
            Circle()
                .fill(colorForEnergyLevel(energyLevel))
                .frame(width: 36, height: 36)
                .overlay(
                    Text("\(Int(energyLevel * 100))")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
            
            if day == optimalWorkoutDay() {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.caption)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private var strengthTrendView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Strength Projection")
                .font(.title2)
                .fontWeight(.bold)
            
            if strengthTrends.isEmpty {
                Text("Not enough data to project strength trends")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                Chart {
                    ForEach(strengthTrends) { trend in
                        LineMark(
                            x: .value("Week", trend.weekOffset),
                            y: .value("Weight", trend.predictedWeight)
                        )
                        .foregroundStyle(by: .value("Exercise", trend.exerciseName))
                        .symbol(by: .value("Exercise", trend.exerciseName))
                        .symbolSize(30)
                        
                        AreaMark(
                            x: .value("Week", trend.weekOffset),
                            yStart: .value("Lower", trend.lowerBound),
                            yEnd: .value("Upper", trend.upperBound)
                        )
                        .foregroundStyle(by: .value("Exercise", trend.exerciseName))
                        .opacity(0.2)
                    }
                }
                .frame(height: 250)
                .chartXAxisLabel("Weeks From Now")
                .chartYAxisLabel("Projected Max Weight (kg)")
                .chartLegend(position: .bottom)
                .padding()
                .background(Color(.tertiarySystemGroupedBackground))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    private var goalTimelineView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Goal Achievement Timeline")
                .font(.title2)
                .fontWeight(.bold)
            
            if goalTimeline.isEmpty {
                Text("Set specific goals to see achievement predictions")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                VStack(spacing: 0) {
                    ForEach(goalTimeline) { goal in
                        goalTimelineItem(goal)
                        
                        if goalTimeline.last?.id != goal.id {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 2, height: 20)
                                .padding(.leading, 10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding()
                .background(Color(.tertiarySystemGroupedBackground))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    private func goalTimelineItem(_ goal: GoalPrediction) -> some View {
        HStack(alignment: .top, spacing: 15) {
            // Timeline node
            ZStack {
                Circle()
                    .fill(colorForConfidence(goal.confidence))
                    .frame(width: 22, height: 22)
                
                Image(systemName: "trophy.fill")
                    .font(.caption2)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(goal.description)
                        .font(.headline)
                    
                    Spacer()
                    
                    Text(goal.timeFrame)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(colorForConfidence(goal.confidence).opacity(0.1))
                        .cornerRadius(8)
                }
                
                Text(goal.details)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Confidence indicator
                HStack {
                    Text("Confidence:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(Int(goal.confidence * 100))%")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(colorForConfidence(goal.confidence))
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private var focusRecommendationsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Focus Recommendations")
                .font(.title2)
                .fontWeight(.bold)
            
            if focusRecommendations.isEmpty {
                Text("Not enough data to generate focus recommendations")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                VStack(spacing: 10) {
                    ForEach(focusRecommendations) { focus in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: focus.priorityLevel == .high ? "exclamationmark.triangle.fill" :
                                             focus.priorityLevel == .medium ? "arrow.up.circle.fill" : "checkmark.circle.fill")
                                .foregroundColor(focus.priorityLevel == .high ? .red :
                                                focus.priorityLevel == .medium ? .orange : .green)
                                .font(.title3)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("\(focus.muscleGroup) (\(focus.priorityLevel.rawValue))")
                                    .font(.headline)
                                
                                Text(focus.reasonText)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                // Recommended exercises
                                if !focus.recommendedExercises.isEmpty {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Suggested exercises:")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .padding(.top, 4)
                                        
                                        Text(focus.recommendedExercises.joined(separator: ", "))
                                            .font(.caption)
                                            .foregroundColor(.primary)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color(.tertiarySystemGroupedBackground))
                        .cornerRadius(12)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    private var injuryRiskView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Injury Risk Assessment")
                .font(.title2)
                .fontWeight(.bold)
            
            if injuryRiskAreas.isEmpty {
                Text("Not enough data to assess injury risks")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                Chart {
                    ForEach(injuryRiskAreas) { area in
                        BarMark(
                            x: .value("Area", area.bodyPart),
                            y: .value("Risk", area.riskScore * 100)
                        )
                        .foregroundStyle(colorForRisk(area.riskScore))
                        .annotation {
                            Text("\(Int(area.riskScore * 100))%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .frame(height: 200)
                .chartYScale(domain: 0...100)
                .chartYAxisLabel("Risk %")
                .padding()
                .background(Color(.tertiarySystemGroupedBackground))
                .cornerRadius(12)
                
                Text("Based on muscle imbalances, exercise selection, and training patterns")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    // MARK: - Analysis Methods
    
    private func analyzeWorkoutData() {
        Task {
            // Simulate calculation time
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            guard !workouts.isEmpty else {
                await MainActor.run {
                    isLoading = false
                }
                return
            }
            
            // Perform data analysis
            await predictNextWorkout()
            await analyzeOptimalSchedule()
            await projectStrengthTrends()
            await predictGoalTimeline()
            await determineFocusAreas()
            await assessInjuryRisks()
            
            await MainActor.run {
                isLoading = false
            }
        }
    }
    
    private func predictNextWorkout() async {
        // Analyze workout history to suggest next workout
        let mostFrequentWorkouts = findMostFrequentWorkoutTypes()
        let leastWorkedMuscleGroups = findLeastWorkedMuscleGroups()
        
        let optimalDay = optimalWorkoutDay()
        
        // Generate workout name based on least worked muscle groups
        let workoutName: String
        let exercises: [SuggestedExercise]
        let reasonText: String
        
        if let primaryMuscle = leastWorkedMuscleGroups.first {
            workoutName = "\(primaryMuscle) Workout"
            
            // Find exercises for these muscle groups
            exercises = generateExerciseSuggestions(for: leastWorkedMuscleGroups)
            
            reasonText = "This workout focuses on \(primaryMuscle) which has been undertrained compared to other muscle groups in your recent workouts."
        } else if let mostFrequentType = mostFrequentWorkouts.first {
            workoutName = mostFrequentType
            exercises = generateExerciseSuggestions(for: [mostFrequentType])
            reasonText = "Based on your workout history, you tend to enjoy and consistently perform \(mostFrequentType.lowercased()) workouts."
        } else {
            workoutName = "Full Body Workout"
            exercises = generateExerciseSuggestions(for: ["Chest", "Back", "Legs"])
            reasonText = "A balanced full body workout is recommended to maintain overall development."
        }
        
        let suggestion = WorkoutSuggestion(
            name: workoutName,
            optimalDay: optimalDay,
            exercises: exercises,
            reasonText: reasonText
        )
        
        await MainActor.run {
            self.nextWorkoutSuggestion = suggestion
        }
    }
    
    private func analyzeOptimalSchedule() async {
        // Determine optimal workout days based on historical performance
        var schedule: [Int: Double] = [:]
        
        // Get all workouts and analyze performance by day of week
        let calendar = Calendar.current
        
        // Calculate average performance by day of week
        for day in 0..<7 {
            let workoutsOnDay = workouts.filter {
                calendar.component(.weekday, from: $0.date) == day + 1
            }
            
            if workoutsOnDay.isEmpty {
                schedule[day] = 0.5 // Default middle value
                continue
            }
            
            // Calculate average volume for day
            let totalVolume = workoutsOnDay.reduce(0.0) { $0 + $1.totalVolume }
            let avgVolume = totalVolume / Double(workoutsOnDay.count)
            
            // Normalize to 0-1 range based on overall average
            let overallAvgVolume = workouts.reduce(0.0) { $0 + $1.totalVolume } / Double(workouts.count)
            var normalizedScore = avgVolume / (overallAvgVolume * 1.5) // Normalize relative to overall average
            normalizedScore = min(max(normalizedScore, 0.1), 0.9) // Clamp between 0.1 and 0.9
            
            schedule[day] = normalizedScore
        }
        
        await MainActor.run {
            self.workoutSchedule = schedule
        }
    }
    
    private func projectStrengthTrends() async {
        // Project strength trends for key exercises
        var trends: [StrengthTrend] = []
        
        // Find key compound exercises
        let compoundExercises = ["Bench Press", "Squat", "Deadlift", "Overhead Press"]
        
        for exerciseName in compoundExercises {
            // Find all instances of this exercise
            let exerciseInstances = workouts.flatMap { workout in
                workout.exercises.filter { exercise in
                    exerciseViewModel.getExerciseName(for: exercise.exerciseID).contains(exerciseName)
                }
            }
            
            guard exerciseInstances.count >= 3 else { continue }
            
            // Get max weight for each workout with this exercise
            var weightData: [(date: Date, weight: Double)] = []
            
            for exercise in exerciseInstances {
                if let maxSet = exercise.sets.filter({ !$0.isWarmupSet }).max(by: { $0.weight < $1.weight }) {
                    weightData.append((date: exercise.workout?.date ?? Date(), weight: maxSet.weight))
                }
            }
            
            // Sort by date
            weightData.sort { $0.date < $1.date }
            
            // Calculate weekly progress rate
            guard weightData.count >= 2,
                  let firstEntry = weightData.first,
                  let lastEntry = weightData.last else { continue }
            
            let totalWeeks = lastEntry.date.timeIntervalSince(firstEntry.date) / (7 * 86400)
            let totalProgress = lastEntry.weight - firstEntry.weight
            
            guard totalWeeks > 0 else { continue }
            
            let weeklyProgressRate = totalProgress / totalWeeks
            
            // Project for future weeks
            let latestWeight = lastEntry.weight
            let projectionWeeks = 12
            
            for week in 1...projectionWeeks {
                // Apply diminishing returns model for more realistic projections
                let diminishingFactor = 1.0 / log(Double(week) + 2)
                let projectedProgress = weeklyProgressRate * diminishingFactor * Double(week)
                let predictedWeight = latestWeight + projectedProgress
                
                // Calculate confidence interval (widens with time)
                let uncertaintyFactor = Double(week) * 0.01 * latestWeight
                let lowerBound = predictedWeight - uncertaintyFactor
                let upperBound = predictedWeight + uncertaintyFactor
                
                trends.append(StrengthTrend(
                    exerciseName: exerciseName,
                    weekOffset: week,
                    predictedWeight: predictedWeight,
                    lowerBound: lowerBound,
                    upperBound: upperBound
                ))
            }
        }
        
        await MainActor.run {
            self.strengthTrends = trends
        }
    }
    
    private func predictGoalTimeline() async {
        // Generate predicted goal achievements based on progress rates
        var goals: [GoalPrediction] = []
        
        // Baseline data
        let sortedWorkouts = workouts.sorted { $0.date < $1.date }
        let startingStrength = calculateStartingStrength()
        let currentStrength = calculateCurrentStrength()
        let progressRates = calculateProgressRates()
        
        // Sample goals based on current stats and progress
        // 1. Short term goals (1-4 weeks)
        if let benchPress = currentStrength["Bench Press"],
           let benchPressRate = progressRates["Bench Press"] {
            let target = benchPress * 1.05 // 5% increase
            let weeksToAchieve = (target - benchPress) / (benchPressRate * 0.8) // 80% of progress rate to be conservative
            
            if weeksToAchieve > 0 && weeksToAchieve < 5 {
                goals.append(GoalPrediction(
                    description: "Bench Press: \(Int(target))kg",
                    timeFrame: "\(Int(ceil(weeksToAchieve))) weeks",
                    details: "Current: \(Int(benchPress))kg, progress rate: \(String(format: "%.1f", benchPressRate))kg/week",
                    confidence: 0.85
                ))
            }
        }
        
        // 2. Medium term goals (1-3 months)
        if let squat = currentStrength["Squat"],
           let squatRate = progressRates["Squat"] {
            let target = squat * 1.10 // 10% increase
            let weeksToAchieve = (target - squat) / (squatRate * 0.7) // 70% of progress rate
            
            if weeksToAchieve > 0 {
                let timeText = weeksToAchieve > 8 ? "\(Int(ceil(weeksToAchieve / 4))) months" : "\(Int(ceil(weeksToAchieve))) weeks"
                goals.append(GoalPrediction(
                    description: "Squat: \(Int(target))kg",
                    timeFrame: timeText,
                    details: "Current: \(Int(squat))kg, progress rate: \(String(format: "%.1f", squatRate))kg/week",
                    confidence: 0.7
                ))
            }
        }
        
        // 3. Long term goals (3-6 months)
        if let deadlift = currentStrength["Deadlift"],
           let deadliftRate = progressRates["Deadlift"] {
            let target = deadlift * 1.15 // 15% increase
            let weeksToAchieve = (target - deadlift) / (deadliftRate * 0.6) // 60% of progress rate for long term
            
            if weeksToAchieve > 0 {
                let months = Int(ceil(weeksToAchieve / 4.3))
                goals.append(GoalPrediction(
                    description: "Deadlift: \(Int(target))kg",
                    timeFrame: "\(months) months",
                    details: "Current: \(Int(deadlift))kg, expect slower gains for long-term goals",
                    confidence: 0.6
                ))
            }
        }
        
        // 4. Volume-based goal
        if workouts.count >= 5 {
            let avgWorkoutsPerWeek = calculateWorkoutsPerWeek()
            let avgVolumePerWorkout = calculateAverageVolume()
            
            let targetTotalVolume = avgVolumePerWorkout * avgWorkoutsPerWeek * 4 * 1.1 // 10% more than current monthly volume
            
            goals.append(GoalPrediction(
                description: "Monthly Volume: \(Int(targetTotalVolume))kg",
                timeFrame: "1 month",
                details: "Achievable with \(String(format: "%.1f", avgWorkoutsPerWeek)) workouts per week at current intensity",
                confidence: 0.75
            ))
        }
        
        // Sort by time to achieve (shortest first)
        await MainActor.run {
            self.goalTimeline = goals
        }
    }
    
    private func determineFocusAreas() async {
        // Analyze muscle group balance and determine focus areas
        var focusAreas: [MuscleGroupFocus] = []
        
        // Get volume by muscle group
        let volumeByMuscle = calculateVolumeByMuscleGroup()
        
        // Calculate average volume per muscle group
        let totalVolume = volumeByMuscle.values.reduce(0, +)
        let muscleGroupCount = max(1, volumeByMuscle.count)
        let averageVolume = totalVolume / Double(muscleGroupCount)
        
        // Find imbalances
        for (muscle, volume) in volumeByMuscle {
            let ratio = volume / averageVolume
            
            // Determine priority level based on ratio
            let priority: PriorityLevel
            let reasonText: String
            let recommendedExercises: [String]
            
            if ratio < 0.6 {
                // Significantly undertrained
                priority = .high
                reasonText = "\(muscle) is significantly undertrained compared to other muscle groups (only \(Int(ratio * 100))% of average volume)"
                recommendedExercises = getRecommendedExercises(for: muscle, count: 3)
            } else if ratio < 0.8 {
                // Moderately undertrained
                priority = .medium
                reasonText = "\(muscle) could use more focus in your training routine"
                recommendedExercises = getRecommendedExercises(for: muscle, count: 2)
            } else if ratio > 1.4 {
                // Significantly overtrained
                priority = .low
                reasonText = "\(muscle) appears to be trained more than other muscle groups, consider reducing volume"
                recommendedExercises = []
            } else {
                // Well-balanced, no need to include
                continue
            }
            
            focusAreas.append(MuscleGroupFocus(
                muscleGroup: muscle,
                priorityLevel: priority,
                reasonText: reasonText,
                recommendedExercises: recommendedExercises
            ))
        }
        
        // Sort by priority (highest first)
        let sortedFocusAreas = focusAreas.sorted { $0.priorityLevel.rawValue > $1.priorityLevel.rawValue }
        
        await MainActor.run {
            self.focusRecommendations = sortedFocusAreas
        }
    }
    
    private func assessInjuryRisks() async {
        // Analyze potential injury risks based on imbalances and patterns
        var riskAreas: [InjuryRiskArea] = []
        
        // Calculate muscle imbalances
        let muscleBalances = calculateMuscleBalances()
        
        // Common imbalance pairs that can lead to injuries
        let imbalancePairs: [(primary: String, secondary: String, bodyPart: String)] = [
            ("Chest", "Back", "Shoulders"),
            ("Quadriceps", "Hamstrings", "Knees"),
            ("Biceps", "Triceps", "Elbows"),
            ("Anterior Deltoid", "Posterior Deltoid", "Rotator Cuff"),
            ("Abdominals", "Lower Back", "Lower Back")
        ]
        
        // Evaluate each imbalance pair
        for pair in imbalancePairs {
            let primaryVolume = muscleBalances[pair.primary, default: 0]
            let secondaryVolume = muscleBalances[pair.secondary, default: 0]
            
            if primaryVolume > 0 && secondaryVolume > 0 {
                // Calculate imbalance ratio
                let ratio = max(primaryVolume, secondaryVolume) / min(primaryVolume, secondaryVolume)
                
                // Convert to risk score (1.0 = balanced, higher = more imbalanced)
                var riskScore = 0.0
                
                if ratio > 1.0 {
                    // Map ratio to risk score: 1.0 = 0%, 2.0 = 50%, 3.0+ = 80%+
                    riskScore = min(0.8, (ratio - 1.0) * 0.5)
                    
                    // Add details about which muscle is stronger
                    let strongerMuscle = primaryVolume > secondaryVolume ? pair.primary : pair.secondary
                    let weakerMuscle = primaryVolume > secondaryVolume ? pair.secondary : pair.primary
                    
                    let details = "\(strongerMuscle) is \(Int((ratio - 1) * 100))% stronger than \(weakerMuscle)"
                    
                    riskAreas.append(InjuryRiskArea(
                        bodyPart: pair.bodyPart,
                        riskScore: riskScore,
                        details: details
                    ))
                }
            }
        }
        
        // Add risk assessment for specific exercise patterns
        if let squatRisk = assessSquatSafetyRisk() {
            riskAreas.append(squatRisk)
        }
        
        if let deadliftRisk = assessDeadliftSafetyRisk() {
            riskAreas.append(deadliftRisk)
        }
        
        // Sort by risk level (highest first)
        let sortedRisks = riskAreas.sorted { $0.riskScore > $1.riskScore }
        
        await MainActor.run {
            self.injuryRiskAreas = sortedRisks
        }
    }
    
    // MARK: - Helper Methods
    
    private func findMostFrequentWorkoutTypes() -> [String] {
        let workoutNameCounts = workouts.reduce(into: [String: Int]()) { counts, workout in
            counts[workout.name, default: 0] += 1
        }
        
        return Array(workoutNameCounts.sorted { $0.value > $1.value }.prefix(3).map { $0.key })
    }
    
    private func findLeastWorkedMuscleGroups() -> [String] {
        let volumeByMuscle = calculateVolumeByMuscleGroup()
        
        guard !volumeByMuscle.isEmpty else { return ["Full Body"] }
        
        // Sort by volume (ascending) and take the bottom 2
        return Array(volumeByMuscle.sorted { $0.value < $1.value }.prefix(2).map { $0.key })
    }
    
    private func calculateVolumeByMuscleGroup() -> [String: Double] {
        var volumeByMuscle: [String: Double] = [:]
        
        for workout in workouts {
            for exercise in workout.exercises {
                if let actualExercise = exerciseViewModel.exercises.first(where: { $0.id == exercise.exerciseID }) {
                    // Add primary muscles (full volume)
                    for muscle in actualExercise.primaryMuscles {
                        volumeByMuscle[muscle.rawValue.capitalized, default: 0] += exercise.totalVolume
                    }
                    
                    // Add secondary muscles (half volume)
                    for muscle in actualExercise.secondaryMuscles {
                        volumeByMuscle[muscle.rawValue.capitalized, default: 0] += exercise.totalVolume * 0.5
                    }
                }
            }
        }
        
        return volumeByMuscle
    }
    
    private func calculateMuscleBalances() -> [String: Double] {
        // Similar to volume by muscle group but normalized for comparison
        return calculateVolumeByMuscleGroup()
    }
    
    private func generateExerciseSuggestions(for muscleGroups: [String]) -> [SuggestedExercise] {
        var suggestions: [SuggestedExercise] = []
        
        // Get relevant exercises for these muscle groups
        let relevantExercises = exerciseViewModel.exercises.filter { exercise in
            let primaryMuscleNames = exercise.primaryMuscles.map { $0.rawValue.capitalized }
            return muscleGroups.contains { muscleGroup in
                primaryMuscleNames.contains { $0.contains(muscleGroup) || muscleGroup.contains($0) }
            }
        }
        
        // Get most frequently performed exercises for these muscle groups
        let frequentExerciseIDs = workouts.flatMap { $0.exercises }.reduce(into: [String: Int]()) { counts, exercise in
            counts[exercise.exerciseID, default: 0] += 1
        }
        
        // Sort exercises by frequency
        let sortedExercises = relevantExercises.sorted { ex1, ex2 in
            let freq1 = frequentExerciseIDs[ex1.id, default: 0]
            let freq2 = frequentExerciseIDs[ex2.id, default: 0]
            return freq1 > freq2
        }
        
        // Take top 3-5 exercises
        let count = min(5, max(3, sortedExercises.count))
        let selectedExercises = Array(sortedExercises.prefix(count))
        
        // Convert to suggestions
        for (index, exercise) in selectedExercises.enumerated() {
            suggestions.append(SuggestedExercise(
                id: exercise.id,
                name: exercise.name,
                sets: index < 2 ? 4 : 3, // More sets for primary exercises
                isPrimary: index < 2, // First 2 are primary
                muscleGroup: exercise.primaryMuscles.first?.rawValue.capitalized ?? "Unknown"
            ))
        }
        
        return suggestions
    }
    
    private func getRecommendedExercises(for muscleGroup: String, count: Int) -> [String] {
        // Find exercises that target this muscle group
        let matchingExercises = exerciseViewModel.exercises.filter { exercise in
            let primaryMuscleNames = exercise.primaryMuscles.map { $0.rawValue.capitalized }
            return primaryMuscleNames.contains { $0.contains(muscleGroup) || muscleGroup.contains($0) }
        }
        
        return Array(matchingExercises.map { $0.name }.prefix(count))
    }
    
    private func optimalWorkoutDay() -> Int {
        // Find the day with highest historical performance
        guard !workoutSchedule.isEmpty else { return 1 } // Default to Monday
        
        return workoutSchedule.max { $0.value < $1.value }?.key ?? 1
    }
    
    private func calculateWorkoutsPerWeek() -> Double {
        let sortedWorkouts = workouts.sorted { $0.date < $1.date }
        
        guard sortedWorkouts.count >= 2 else { return Double(workouts.count) }
        
        let firstDate = sortedWorkouts.first!.date
        let lastDate = sortedWorkouts.last!.date
        let weeksDifference = lastDate.timeIntervalSince(firstDate) / (7 * 86400)
        
        guard weeksDifference > 0 else { return Double(workouts.count) }
        
        return Double(workouts.count) / weeksDifference
    }
    
    private func calculateAverageVolume() -> Double {
        guard !workouts.isEmpty else { return 0 }
        
        let totalVolume = workouts.reduce(0.0) { $0 + $1.totalVolume }
        return totalVolume / Double(workouts.count)
    }
    
    private func calculateStartingStrength() -> [String: Double] {
        // Calculate starting strength for key exercises
        var startingStrength: [String: Double] = [:]
        let sortedWorkouts = workouts.sorted { $0.date < $1.date }
        
        // Get first few workouts
        let initialWorkouts = Array(sortedWorkouts.prefix(min(3, sortedWorkouts.count)))
        
        // Find max weights for common exercises
        for workout in initialWorkouts {
            for exercise in workout.exercises {
                let exerciseName = exerciseViewModel.getExerciseName(for: exercise.exerciseID)
                
                // Check if it's a key exercise
                if isKeyExercise(exerciseName) {
                    // Find max weight
                    if let maxSet = exercise.sets.filter({ !$0.isWarmupSet }).max(by: { $0.weight < $1.weight }) {
                        // Store highest weight for each exercise
                        let currentMax = startingStrength[exerciseName, default: 0]
                        startingStrength[exerciseName] = max(currentMax, maxSet.weight)
                    }
                }
            }
        }
        
        return startingStrength
    }
    
    private func calculateCurrentStrength() -> [String: Double] {
        // Calculate current strength for key exercises
        var currentStrength: [String: Double] = [:]
        let sortedWorkouts = workouts.sorted { $0.date < $1.date }
        
        // Get most recent workouts
        let recentWorkouts = Array(sortedWorkouts.suffix(min(3, sortedWorkouts.count)))
        
        // Find max weights for common exercises
        for workout in recentWorkouts {
            for exercise in workout.exercises {
                let exerciseName = exerciseViewModel.getExerciseName(for: exercise.exerciseID)
                
                // Check if it's a key exercise
                if isKeyExercise(exerciseName) {
                    // Find max weight
                    if let maxSet = exercise.sets.filter({ !$0.isWarmupSet }).max(by: { $0.weight < $1.weight }) {
                        // Store highest weight for each exercise
                        let currentMax = currentStrength[exerciseName, default: 0]
                        currentStrength[exerciseName] = max(currentMax, maxSet.weight)
                    }
                }
            }
        }
        
        return currentStrength
    }
    
    private func calculateProgressRates() -> [String: Double] {
        // Calculate progress rates for key exercises
        var progressRates: [String: Double] = [:]
        
        let startingStrengths = calculateStartingStrength()
        let currentStrengths = calculateCurrentStrength()
        
        // Calculate time span
        let sortedWorkouts = workouts.sorted { $0.date < $1.date }
        guard let firstDate = sortedWorkouts.first?.date,
              let lastDate = sortedWorkouts.last?.date else {
            return [:]
        }
        
        let weeksDifference = max(1, lastDate.timeIntervalSince(firstDate) / (7 * 86400))
        
        // Calculate weekly progress for each exercise
        for (exercise, currentStrength) in currentStrengths {
            if let startingStrength = startingStrengths[exercise] {
                let totalProgress = currentStrength - startingStrength
                let weeklyProgress = totalProgress / weeksDifference
                
                progressRates[exercise] = weeklyProgress
            }
        }
        
        return progressRates
    }
    
    private func isKeyExercise(_ name: String) -> Bool {
        let keyExercises = ["Bench Press", "Squat", "Deadlift", "Shoulder Press", "Overhead Press", "Row"]
        return keyExercises.contains { name.contains($0) }
    }
    
    private func assessSquatSafetyRisk() -> InjuryRiskArea? {
        // Find squat exercises
        let squatExercises = workouts.flatMap { workout in
            workout.exercises.filter { exercise in
                exerciseViewModel.getExerciseName(for: exercise.exerciseID).contains("Squat")
            }
        }
        
        guard !squatExercises.isEmpty else { return nil }
        
        // Check weight progression pattern
        // Rapid weight increases can be a risk factor
        var weights: [Double] = []
        
        for exercise in squatExercises {
            if let maxSet = exercise.sets.filter({ !$0.isWarmupSet }).max(by: { $0.weight < $1.weight }) {
                weights.append(maxSet.weight)
            }
        }
        
        guard weights.count >= 3 else { return nil }
        
        // Calculate average weight increase per session
        var weightIncreases: [Double] = []
        for i in 1..<weights.count {
            let increase = weights[i] - weights[i-1]
            weightIncreases.append(increase)
        }
        
        let avgIncrease = weightIncreases.reduce(0, +) / Double(weightIncreases.count)
        
        // If average increase is more than 5% of the weight, flag as potential risk
        let avgWeight = weights.reduce(0, +) / Double(weights.count)
        let increasePercentage = (avgIncrease / avgWeight) * 100
        
        if increasePercentage > 5 {
            let riskScore = min(0.8, increasePercentage / 20) // Cap at 80%
            
            return InjuryRiskArea(
                bodyPart: "Knees/Lower Back",
                riskScore: riskScore,
                details: "Rapid squat weight progression of \(Int(increasePercentage))% per session"
            )
        }
        
        return nil
    }
    
    private func assessDeadliftSafetyRisk() -> InjuryRiskArea? {
        // Find deadlift exercises
        let deadliftExercises = workouts.flatMap { workout in
            workout.exercises.filter { exercise in
                exerciseViewModel.getExerciseName(for: exercise.exerciseID).contains("Deadlift")
            }
        }
        
        guard !deadliftExercises.isEmpty else { return nil }
        
        // Check volume pattern - high volume deadlifts can increase injury risk
        var setsPerWorkout: [Int] = []
        
        for exercise in deadliftExercises {
            let nonWarmupSets = exercise.sets.filter { !$0.isWarmupSet }.count
            setsPerWorkout.append(nonWarmupSets)
        }
        
        let avgSets = Double(setsPerWorkout.reduce(0, +)) / Double(max(1, setsPerWorkout.count))
        
        // High volume deadlifts (more than 5 working sets) can increase risk
        if avgSets > 5 {
            let riskScore = min(0.7, (avgSets - 5) * 0.1 + 0.3) // 0.3 at 5 sets, increasing
            
            return InjuryRiskArea(
                bodyPart: "Lower Back",
                riskScore: riskScore,
                details: "High deadlift volume: \(String(format: "%.1f", avgSets)) sets per session"
            )
        }
        
        return nil
    }
    
    // MARK: - Formatting Helpers
    
    private func formatWeekday(_ day: Int) -> String {
        let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        return weekdays[day]
    }
    
    private func formatOptimalDay(_ day: Int) -> String {
        let weekdays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        return weekdays[day]
    }
    
    private func colorForEnergyLevel(_ level: Double) -> Color {
        if level < 0.3 {
            return Color.gray.opacity(0.7)
        } else if level < 0.6 {
            return Color.green
        } else {
            return Color.blue
        }
    }
    
    private func colorForConfidence(_ confidence: Double) -> Color {
        if confidence < 0.5 {
            return .orange
        } else if confidence < 0.7 {
            return .blue
        } else {
            return .green
        }
    }
    
    private func colorForRisk(_ risk: Double) -> Color {
        if risk < 0.3 {
            return .green
        } else if risk < 0.6 {
            return .orange
        } else {
            return .red
        }
    }
}

// MARK: - Supporting Models

struct WorkoutSuggestion {
    let name: String
    let optimalDay: Int
    let exercises: [SuggestedExercise]
    let reasonText: String
}

struct SuggestedExercise: Identifiable {
    let id: String
    let name: String
    let sets: Int
    let isPrimary: Bool
    let muscleGroup: String
}

struct StrengthTrend: Identifiable {
    let id = UUID()
    let exerciseName: String
    let weekOffset: Int
    let predictedWeight: Double
    let lowerBound: Double
    let upperBound: Double
}

struct GoalPrediction: Identifiable {
    let id = UUID()
    let description: String
    let timeFrame: String
    let details: String
    let confidence: Double // 0-1
}

enum PriorityLevel: String, Comparable {
    case high = "High Priority"
    case medium = "Medium Priority"
    case low = "Low Priority"
    
    static func < (lhs: PriorityLevel, rhs: PriorityLevel) -> Bool {
        let order: [PriorityLevel] = [.low, .medium, .high]
        return order.firstIndex(of: lhs)! < order.firstIndex(of: rhs)!
    }
}

struct MuscleGroupFocus: Identifiable {
    let id = UUID()
    let muscleGroup: String
    let priorityLevel: PriorityLevel
    let reasonText: String
    let recommendedExercises: [String]
}

struct InjuryRiskArea: Identifiable {
    let id = UUID()
    let bodyPart: String
    let riskScore: Double // 0-1
    let details: String
}
