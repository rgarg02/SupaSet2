import SwiftUI
import SwiftData
import Charts

struct ResearchInsightsSection: View {
    let selectedPeriod: StatsPeriod
    @Environment(ExerciseViewModel.self) private var exerciseViewModel
    @Query private var workouts: [Workout]
    
    // State variables
    @State private var isLoading = true
    @State private var selectedInsightCategory: InsightCategory = .hypertrophy
    @State private var expandedInsight: String? = nil
    
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
        VStack(spacing: 20) {
            if isLoading {
                loadingView
            } else {
                // Category Selector
                insightCategoryPicker
                
                // Research Insights based on selected category
                insightsForSelectedCategory
                
                // Personalized Recommendations based on workout data
                personalizedRecommendationsSection
                
                // References
                referencesSection
            }
        }
        .onAppear { loadData() }
        .onChange(of: selectedPeriod) {
            isLoading = true
            loadData()
        }
        .onChange(of: selectedInsightCategory) {
            // No need to reload data, just update UI
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 30) {
            ProgressView()
                .scaleEffect(1.5)
                .padding(.top, 40)
            Text("Loading research insights...")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, minHeight: 300)
    }
    
    // MARK: - Category Picker
    
    private var insightCategoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(InsightCategory.allCases) { category in
                    categoryButton(for: category)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func categoryButton(for category: InsightCategory) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedInsightCategory = category
            }
        }) {
            VStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.title2)
                    .foregroundColor(selectedInsightCategory == category ? .white : .primary)
                Text(category.rawValue)
                    .font(.subheadline)
                    .foregroundColor(selectedInsightCategory == category ? .white : .primary)
            }
            .frame(width: 100, height: 70)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(selectedInsightCategory == category ? Color.blue : Color(.secondarySystemBackground))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Category Content
    
    private var insightsForSelectedCategory: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("\(selectedInsightCategory.rawValue) Research")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(selectedInsightCategory.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom, 4)
            
            // Display insights for the selected category
            ForEach(researchInsights(for: selectedInsightCategory)) { insight in
                insightCard(insight: insight)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    private func insightCard(insight: ResearchInsight) -> some View {
        let isExpanded = expandedInsight == insight.id
        
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: insight.icon)
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(width: 24, height: 24)
                
                Text(insight.title)
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        expandedInsight = isExpanded ? nil : insight.id
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                }
            }
            
            if isExpanded {
                Text(insight.content)
                    .font(.subheadline)
                    .padding(.top, 4)
                
                HStack {
                    Spacer()
                    Text("Source: \(insight.source)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(.tertiarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Personalized Recommendations
    
    private var personalizedRecommendationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Personalized Recommendations")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Based on your workout history and research findings")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ForEach(personalizedRecommendations()) { recommendation in
                HStack(alignment: .top) {
                    Image(systemName: recommendation.icon)
                        .font(.title3)
                        .foregroundColor(.green)
                        .frame(width: 28, height: 28)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(recommendation.title)
                            .font(.headline)
                        
                        Text(recommendation.content)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
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
    
    // MARK: - References Section
    
    private var referencesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("References")
                .font(.headline)
            
            Text("Our insights are based on peer-reviewed research:")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(scientificReferences, id: \.self) { reference in
                    Text("• \(reference)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Text("Note: Individual responses to training may vary based on factors such as genetics, nutrition, sleep quality, and overall stress levels.")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 8)
        }
        .padding()
        .background(Color(.tertiarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Data and Calculations
    
    private func loadData() {
        Task {
            // Simulate loading time for better UX
            try? await Task.sleep(nanoseconds: 500_000_000)
            await MainActor.run { isLoading = false }
        }
    }
    
    // Get research insights for the selected category
    private func researchInsights(for category: InsightCategory) -> [ResearchInsight] {
        switch category {
        case .hypertrophy:
            return hypertrophyInsights
        case .strength:
            return strengthInsights
        case .recovery:
            return recoveryInsights
        case .nutrition:
            return nutritionInsights
        case .technique:
            return techniqueInsights
        }
    }
    
    // Generate personalized recommendations based on workout data
    private func personalizedRecommendations() -> [PersonalizedRecommendation] {
        var recommendations: [PersonalizedRecommendation] = []
        
        // Check training frequency and consistency
        let workoutsPerWeek = calculateWorkoutsPerWeek()
        if workoutsPerWeek < 3 {
            recommendations.append(PersonalizedRecommendation(
                id: "freq_low",
                icon: "calendar.badge.plus",
                title: "Increase Training Frequency",
                content: "Research shows 3-5 sessions per week is optimal for most people. Consider adding 1-2 more workouts per week for better results."
            ))
        } else if workoutsPerWeek > 6 {
            recommendations.append(PersonalizedRecommendation(
                id: "freq_high",
                icon: "calendar.badge.minus",
                title: "Consider More Recovery Time",
                content: "Studies indicate that most natural lifters benefit from at least 1-2 full rest days per week. Make sure you're allowing adequate recovery."
            ))
        }
        
        // Check exercise selection
        let muscleGroups = getMuscleGroupDistribution()
        let muscleImbalances = getMuscleImbalances(from: muscleGroups)
        
        if !muscleImbalances.isEmpty {
            let undertrainedMuscles = muscleImbalances.prefix(2).map { $0.capitalized }.joined(separator: ", ")
            recommendations.append(PersonalizedRecommendation(
                id: "balance",
                icon: "scale.3d",
                title: "Balance Your Training",
                content: "Your data shows you might be undertraining: \(undertrainedMuscles). Research indicates balanced training across all muscle groups leads to better overall development and reduced injury risk."
            ))
        }
        
        // Check for progressive overload
        let hasProgressiveOverload = checkProgressiveOverload()
        if !hasProgressiveOverload {
            recommendations.append(PersonalizedRecommendation(
                id: "prog_overload",
                icon: "chart.line.uptrend.xyaxis",
                title: "Focus on Progressive Overload",
                content: "Studies show that gradually increasing weight, reps, or sets over time is crucial for continuous progress. Try implementing a structured progression scheme in your main lifts."
            ))
        }
        
        // Check volume levels
        let overallVolume = calculateOverallVolume()
        if overallVolume == .low {
            recommendations.append(PersonalizedRecommendation(
                id: "vol_low",
                icon: "plus.square.on.square",
                title: "Increase Training Volume",
                content: "Research suggests 10-20 weekly sets per muscle group for optimal hypertrophy. Consider adding 1-2 sets per exercise or additional exercises to increase your total training volume."
            ))
        } else if overallVolume == .high {
            recommendations.append(PersonalizedRecommendation(
                id: "vol_high",
                icon: "minus.square.on.square",
                title: "Monitor Recovery Capacity",
                content: "Your current volume is on the higher end. Studies show that excessive volume can impair recovery and progress. Consider periodizing your training with deload weeks."
            ))
        }
        
        // Add specific recommendations based on training history
        let mostFrequentExercises = getMostFrequentExercises(limit: 3)
        if mostFrequentExercises.contains(where: { $0.lowercased().contains("bench press") }) {
            recommendations.append(PersonalizedRecommendation(
                id: "bench_tech",
                icon: "figure.strengthtraining.traditional",
                title: "Optimize Bench Press Technique",
                content: "Studies show that maintaining scapular retraction and proper arch can increase pec activation by 20-30% while reducing shoulder strain. Consider a form check on your bench press."
            ))
        }
        
        // Default recommendation if none generated
        if recommendations.isEmpty {
            recommendations.append(PersonalizedRecommendation(
                id: "default",
                icon: "checkmark.circle",
                title: "You're On The Right Track",
                content: "Your training patterns align well with research-backed principles. Continue your consistent approach to training and recovery."
            ))
        }
        
        return recommendations.prefix(3).map { $0 } // Limit to top 3 recommendations
    }
    
    // MARK: - Helper Functions
    
    private func calculateWorkoutsPerWeek() -> Double {
        let calendar = Calendar.current
        
        guard !workouts.isEmpty else { return 0 }
        
        // For recent periods, use actual workout count divided by weeks
        if selectedPeriod != .allTime && selectedPeriod != .year {
            if let daysBack = selectedPeriod.daysBack {
                let weeksInPeriod = Double(daysBack) / 7.0
                return Double(workouts.count) / weeksInPeriod
            }
        }
        
        // For all time or year, calculate based on actual date range
        let sortedWorkouts = workouts.sorted { $0.date < $1.date }
        guard sortedWorkouts.count >= 2 else { return Double(workouts.count) } // Edge case
        
        let firstDate = sortedWorkouts.first!.date
        let lastDate = sortedWorkouts.last!.date
        let weeksElapsed = max(1, lastDate.timeIntervalSince(firstDate) / (86400 * 7))
        
        return Double(workouts.count) / weeksElapsed
    }
    
    private func getMuscleGroupDistribution() -> [String: Double] {
        var volumeByMuscle: [String: Double] = [:]
        
        for workout in workouts {
            for exercise in workout.exercises {
                if let actualExercise = exerciseViewModel.exercises.first(where: { $0.id == exercise.exerciseID }) {
                    // Add primary muscles (full volume)
                    for muscle in actualExercise.primaryMuscles {
                        volumeByMuscle[muscle.rawValue, default: 0] += exercise.totalVolume
                    }
                    
                    // Add secondary muscles (half volume)
                    for muscle in actualExercise.secondaryMuscles {
                        volumeByMuscle[muscle.rawValue, default: 0] += exercise.totalVolume * 0.5
                    }
                }
            }
        }
        
        return volumeByMuscle
    }
    
    private func getMuscleImbalances(from distribution: [String: Double]) -> [String] {
        guard !distribution.isEmpty else { return [] }
        
        // Calculate average volume
        let totalVolume = distribution.values.reduce(0, +)
        let averageVolume = totalVolume / Double(distribution.count)
        
        // Find muscles with less than 70% of average volume
        return distribution
            .filter { $0.value < averageVolume * 0.7 }
            .sorted { $0.value < $1.value }
            .map { $0.key }
    }
    
    private func checkProgressiveOverload() -> Bool {
        // Look at compound lifts progress over time
        let compoundExercises = ["Bench Press", "Squat", "Deadlift", "Overhead Press"]
        
        // Get all exercises from workouts
        let allExercises = workouts.flatMap { $0.exercises }
        
        // Filter to just compound movements
        let compoundIDs = Set(allExercises.compactMap { exercise -> String? in
            let name = exerciseViewModel.getExerciseName(for: exercise.exerciseID)
            return compoundExercises.contains(where: { name.contains($0) }) ? exercise.exerciseID : nil
        })
        
        guard !compoundIDs.isEmpty else { return false }
        
        // For each compound lift, check if weights are increasing over time
        var hasProgression = false
        
        for exerciseID in compoundIDs {
            // Get all instances of this exercise, sorted by date
            let exerciseInstances = workouts
                .filter { workout in workout.exercises.contains { $0.exerciseID == exerciseID } }
                .sorted { $0.date < $1.date }
            
            guard exerciseInstances.count >= 3 else { continue } // Need at least 3 data points
            
            // Get max weight for each instance
            let maxWeights = exerciseInstances.compactMap { workout -> Double? in
                guard let exercise = workout.exercises.first(where: { $0.exerciseID == exerciseID }) else {
                    return nil
                }
                
                return exercise.sets
                    .filter { !$0.isWarmupSet }
                    .map { $0.weight }
                    .max()
            }
            
            // Check if there's a trend of increasing weights
            // Simple check: is the max weight in the last third higher than in the first third?
            let firstThird = maxWeights.prefix(maxWeights.count / 3)
            let lastThird = maxWeights.suffix(maxWeights.count / 3)
            
            if !firstThird.isEmpty && !lastThird.isEmpty {
                let firstAvg = firstThird.reduce(0, +) / Double(firstThird.count)
                let lastAvg = lastThird.reduce(0, +) / Double(lastThird.count)
                
                if lastAvg > firstAvg * 1.05 { // 5% increase is significant
                    hasProgression = true
                    break
                }
            }
        }
        
        return hasProgression
    }
    
    private enum VolumeLevel {
        case low, medium, high
    }
    
    private func calculateOverallVolume() -> VolumeLevel {
        let muscleVolumes = getMuscleGroupDistribution()
        
        guard !muscleVolumes.isEmpty else { return .medium }
        
        // Calculate sets per muscle group per week
        let weeksInPeriod = calculateWeeksInPeriod()
        let averageVolumePerMusclePerWeek = muscleVolumes.mapValues { $0 / weeksInPeriod }
        
        // Convert to approximate sets
        // Rough estimate: 1 set = 400 volume units (e.g., 10 reps × 40kg)
        let setsPerMusclePerWeek = averageVolumePerMusclePerWeek.mapValues { $0 / 400 }
        
        // Calculate average sets across all muscles
        let avgSets = setsPerMusclePerWeek.values.reduce(0, +) / Double(setsPerMusclePerWeek.count)
        
        // Based on scientific literature:
        // < 8 sets per week per muscle group: low volume
        // 8-15 sets per week per muscle group: medium volume
        // > 15 sets per week per muscle group: high volume
        if avgSets < 8 {
            return .low
        } else if avgSets > 15 {
            return .high
        } else {
            return .medium
        }
    }
    
    private func calculateWeeksInPeriod() -> Double {
        if let daysBack = selectedPeriod.daysBack {
            return Double(daysBack) / 7.0
        } else {
            // For all time, calculate from first to last workout
            let sortedWorkouts = workouts.sorted { $0.date < $1.date }
            guard sortedWorkouts.count >= 2 else { return 1.0 }
            
            let firstDate = sortedWorkouts.first!.date
            let lastDate = sortedWorkouts.last!.date
            let days = lastDate.timeIntervalSince(firstDate) / 86400
            
            return max(days / 7, 1.0)
        }
    }
    
    private func getMostFrequentExercises(limit: Int) -> [String] {
        let exerciseCounts = workouts.flatMap { $0.exercises }.reduce(into: [String: Int]()) { counts, exercise in
            let name = exerciseViewModel.getExerciseName(for: exercise.exerciseID)
            counts[name, default: 0] += 1
        }
        
        return exerciseCounts
            .sorted { $0.value > $1.value }
            .prefix(limit)
            .map { $0.key }
    }
    
    // MARK: - Research Data
    
    private var hypertrophyInsights: [ResearchInsight] {
        [
            ResearchInsight(
                id: "hyp1",
                icon: "dumbbell.fill",
                title: "Optimal Training Volume",
                content: "Research shows that 10-20 sets per muscle group per week appears to be the sweet spot for maximizing muscle hypertrophy in most individuals. This volume can be achieved across multiple sessions to avoid excessive fatigue in a single workout.",
                source: "Schoenfeld et al., 2017"
            ),
            ResearchInsight(
                id: "hyp2",
                icon: "gauge.high",
                title: "Rep Range Flexibility",
                content: "While the traditional 8-12 rep range has long been prescribed for hypertrophy, recent research indicates that similar growth occurs with both lower (4-8) and higher (15-30) rep ranges when sets are taken to or near failure, as long as total volume is equated.",
                source: "Schoenfeld et al., 2021"
            ),
            ResearchInsight(
                id: "hyp3",
                icon: "list.bullet.clipboard",
                title: "Exercise Variety",
                content: "Including a variety of exercises that target a muscle group from different angles appears to maximize muscle development. This is because different regions of a muscle may be preferentially activated depending on the exercise selection and execution.",
                source: "Fonseca et al., 2020"
            ),
            ResearchInsight(
                id: "hyp4",
                icon: "clock.arrow.circlepath",
                title: "Rest Interval Impact",
                content: "Longer rest intervals (2-3 minutes) between sets appear to maximize muscle growth by allowing greater force production on subsequent sets, especially for compound movements. This challenges traditional bodybuilding approaches of short rest periods.",
                source: "Grgic et al., 2018"
            )
        ]
    }
    
    private var strengthInsights: [ResearchInsight] {
        [
            ResearchInsight(
                id: "str1",
                icon: "figure.strengthtraining.traditional",
                title: "Optimal Rep Range",
                content: "For maximal strength development, training in the 1-6 rep range with heavy loads (80-95% of 1RM) appears most effective. However, including some medium-rep training (6-12) can provide additional benefits for neural adaptations and work capacity.",
                source: "Ratamess et al., 2009"
            ),
            ResearchInsight(
                id: "str2",
                icon: "brain.head.profile",
                title: "Neural Adaptations",
                content: "The early phase of strength gains (first 8-12 weeks) is primarily driven by neural adaptations rather than muscle growth. These include improved motor unit recruitment, firing frequency, and inter-muscular coordination.",
                source: "Carroll et al., 2011"
            ),
            ResearchInsight(
                id: "str3",
                icon: "arrow.up.forward",
                title: "Specificity Principle",
                content: "Strength is highly specific to the movement pattern, velocity, and contraction type used in training. For maximum carryover to specific activities, training should closely mimic the force production demands of the target activity.",
                source: "Sheppard & Young, 2006"
            ),
            ResearchInsight(
                id: "str4",
                icon: "chart.xyaxis.line",
                title: "Periodization Benefits",
                content: "Periodized strength training programs produce superior strength gains compared to non-periodized approaches. Both linear and undulating periodization models have shown effectiveness, with some evidence suggesting undulating models may provide slightly better results for advanced trainees.",
                source: "Williams et al., 2017"
            )
        ]
    }
    
    private var recoveryInsights: [ResearchInsight] {
        [
            ResearchInsight(
                id: "rec1",
                icon: "zzz",
                title: "Sleep Quality and Duration",
                content: "7-9 hours of quality sleep per night is strongly associated with optimal recovery and performance. Sleep deprivation can significantly impair muscle recovery, testosterone production, and training adaptation, while increasing injury risk and reducing workout performance.",
                source: "Dattilo et al., 2011"
            ),
            ResearchInsight(
                id: "rec2",
                icon: "arrow.triangle.2.circlepath",
                title: "Muscle Protein Synthesis",
                content: "Resistance training stimulates muscle protein synthesis for 24-48 hours post-workout in trained individuals. This suggests that training a muscle group 2-3 times per week with appropriate volume distribution may be optimal for most lifters.",
                source: "Damas et al., 2015"
            ),
            ResearchInsight(
                id: "rec3",
                icon: "waveform.path.ecg",
                title: "Active Recovery Benefits",
                content: "Low-intensity activity between training sessions (e.g., walking, light cycling) can enhance recovery by promoting blood flow without causing additional fatigue. This active recovery approach has been shown to reduce DOMS and accelerate performance restoration compared to complete rest.",
                source: "Dupuy et al., 2018"
            ),
            ResearchInsight(
                id: "rec4",
                icon: "arrow.down.circle",
                title: "Deload Importance",
                content: "Periodic deloads (reducing training volume and/or intensity by 30-50% for 4-7 days) can prevent overtraining and promote supercompensation. Research suggests implementing deloads every 4-8 weeks based on training intensity and individual recovery capacity.",
                source: "Kreher & Schwartz, 2012"
            )
        ]
    }
    
    private var nutritionInsights: [ResearchInsight] {
        [
            ResearchInsight(
                id: "nut1",
                icon: "fork.knife",
                title: "Protein Requirements",
                content: "For strength athletes and bodybuilders, protein intake of 1.6-2.2g per kg of bodyweight per day appears optimal for muscle growth and recovery. Higher intakes don't appear to provide additional benefits for most individuals, though they're not harmful.",
                source: "Morton et al., 2018"
            ),
            ResearchInsight(
                id: "nut2",
                icon: "clock.fill",
                title: "Meal Timing and Frequency",
                content: "While the anabolic window isn't as narrow as once thought, consuming 20-40g of protein within a few hours before and after training may optimize muscle protein synthesis. Distributing protein intake across 4-5 meals spaced throughout the day (3-5 hours apart) appears optimal for maximizing muscle growth.",
                source: "Schoenfeld et al., 2018"
            ),
            ResearchInsight(
                id: "nut3",
                icon: "chart.bar.fill",
                title: "Caloric Considerations",
                content: "Small to moderate caloric surpluses (10-20% above maintenance) maximize muscle gain while minimizing fat gain during bulking phases. During cutting phases, moderate deficits (20-25% below maintenance) allow for fat loss while preserving muscle mass, especially when protein intake remains high.",
                source: "Helms et al., 2014"
            ),
            ResearchInsight(
                id: "nut4",
                icon: "flame.fill",
                title: "Carbohydrate Timing",
                content: "Consuming carbohydrates before, during, and/or after high-volume resistance training sessions can enhance performance and recovery, particularly when training sessions exceed 60 minutes or involve multiple muscle groups. 20-40g of carbs with protein post-workout can accelerate glycogen replenishment.",
                source: "Kerksick et al., 2017"
            )
        ]
    }
    
    private var techniqueInsights: [ResearchInsight] {
        [
            ResearchInsight(
                id: "tech1",
                icon: "figure.walk",
                title: "Squat Depth Impact",
                content: "Full-depth squats (below parallel) produce greater muscle activation in the gluteus maximus and quadriceps compared to partial squats, while also creating more favorable adaptations to athletic performance. Contrary to some claims, deep squats do not increase injury risk when performed with proper technique.",
                source: "Kubo et al., 2019"
            ),
            ResearchInsight(
                id: "tech2",
                icon: "arrow.left.and.right.circle",
                title: "Grip Width Effects",
                content: "Bench press grip width significantly affects muscle activation patterns. A wider grip (1.5-2x shoulder width) emphasizes the pectoralis major and anterior deltoid, while a narrower grip increases triceps brachii activation. Both have valid applications depending on training goals.",
                source: "Lehman, 2005"
            ),
            ResearchInsight(
                id: "tech3",
                icon: "slowmo",
                title: "Tempo Training",
                content: "Controlled eccentric (lowering) phases of 2-4 seconds can increase muscle hypertrophy compared to faster eccentrics, likely due to increased time under tension and mechanical damage. However, explosive concentric (lifting) phases may optimize strength and power development.",
                source: "Wilk et al., 2018"
            ),
            ResearchInsight(
                id: "tech4",
                icon: "dot.radiowaves.left.and.right",
                title: "Mind-Muscle Connection",
                content: "Focusing on the target muscle during exercise (internal attentional focus) increases EMG activity in that muscle compared to focusing on the movement itself (external focus). This mind-muscle connection can be particularly beneficial for isolation exercises and hypertrophy training.",
                source: "Schoenfeld & Contreras, 2016"
            )
        ]
    }
    
    private var scientificReferences: [String] {
        [
            "Schoenfeld, B.J., Ogborn, D., & Krieger, J.W. (2017). Dose-response relationship between weekly resistance training volume and increases in muscle mass: A systematic review and meta-analysis. J Sports Sci, 35(11), 1073-1082.",
            
            "Ratamess, N.A., Alvar, B.A., Evetoch, T.K., et al. (2009). Progression models in resistance training for healthy adults. Med Sci Sports Exerc, 41(3), 687-708.",
            
            "Dattilo, M., Antunes, H.K.M., Medeiros, A., et al. (2011). Sleep and muscle recovery: Endocrinological and molecular basis for a new and promising hypothesis. Med Hypotheses, 77(2), 220-222.",
            
            "Morton, R.W., Murphy, K.T., McKellar, S.R., et al. (2018). A systematic review, meta-analysis and meta-regression of the effect of protein supplementation on resistance training-induced gains in muscle mass and strength in healthy adults. Br J Sports Med, 52(6), 376-384.",
            
            "Kubo, K., Ikebukuro, T., & Yata, H. (2019). Effects of squat training with different depths on lower limb muscle volumes. Eur J Appl Physiol, 119(9), 1933-1942.",
            
            "Williams, T.D., Tolusso, D.V., Fedewa, M.V., & Esco, M.R. (2017). Comparison of periodized and non-periodized resistance training on maximal strength: A meta-analysis. Sports Med, 47(10), 2083-2100.",
            
            "Grgic, J., Lazinica, B., Mikulic, P., et al. (2018). The effects of short versus long inter-set rest intervals in resistance training on measures of muscle hypertrophy: A systematic review. Eur J Sport Sci, 17(8), 983-993."
        ]
    }
}

// MARK: - Supporting Models

enum InsightCategory: String, CaseIterable, Identifiable {
    case hypertrophy = "Hypertrophy"
    case strength = "Strength"
    case recovery = "Recovery"
    case nutrition = "Nutrition"
    case technique = "Technique"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .hypertrophy:
            return "figure.arms.open"
        case .strength:
            return "dumbbell.fill"
        case .recovery:
            return "arrow.triangle.2.circlepath"
        case .nutrition:
            return "fork.knife"
        case .technique:
            return "figure.strengthtraining.traditional"
        }
    }
    
    var description: String {
        switch self {
        case .hypertrophy:
            return "Evidence-based principles for optimizing muscle growth"
        case .strength:
            return "Research on maximizing strength development"
        case .recovery:
            return "Science of optimizing rest and adaptation"
        case .nutrition:
            return "Nutritional research for performance and body composition"
        case .technique:
            return "Biomechanics and exercise execution insights"
        }
    }
}

struct ResearchInsight: Identifiable {
    let id: String
    let icon: String
    let title: String
    let content: String
    let source: String
}

struct PersonalizedRecommendation: Identifiable {
    let id: String
    let icon: String
    let title: String
    let content: String
}
