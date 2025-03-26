import SwiftUI
import SwiftData
import Charts

struct MuscleRadarChartView: View {
    // Color properties for customization
    let currentPeriodColor: Color
    let previousPeriodColor: Color
    let currentPeriodFillColor: Color
    let previousPeriodFillColor: Color
    let gridLineColor: Color
    let axisLineColor: Color
    let labelColor: Color
    
    let period: StatsPeriod
    @Query private var currentWorkouts: [SupaSetSchemaV1.Workout]
    @Query private var previousWorkouts: [SupaSetSchemaV1.Workout]
    @State private var currentPeriodData: [MuscleGroupData] = []
    @State private var previousPeriodData: [MuscleGroupData] = []
    @State private var selectedMuscle: String?
    @State private var showConsisedInfo = true
    @Environment(\.modelContext) private var modelContext
    @Environment(ExerciseViewModel.self) private var exerciseViewModel
    
    init(
        period: StatsPeriod,
        currentPeriodColor: Color = .accentColor,
        previousPeriodColor: Color = .secondaryTheme,
        currentPeriodFillColor: Color = .accentColor.opacity(0.4),
        previousPeriodFillColor: Color = Color.secondaryTheme.opacity(0.4),
        gridLineColor: Color = Color.gray.opacity(0.2),
        axisLineColor: Color = Color.gray.opacity(0.4),
        labelColor: Color = .secondary
    ) {
        self.period = period
        self.currentPeriodColor = currentPeriodColor
        self.previousPeriodColor = previousPeriodColor
        self.currentPeriodFillColor = currentPeriodFillColor
        self.previousPeriodFillColor = previousPeriodFillColor
        self.gridLineColor = gridLineColor
        self.axisLineColor = axisLineColor
        self.labelColor = labelColor
        
        // Create predicates for current period
        let currentFromDate: Date?
        if let daysBack = period.daysBack {
            currentFromDate = Calendar.current.date(byAdding: .day, value: -daysBack, to: Date())
        } else {
            currentFromDate = nil // All time
        }
        
        let currentPredicate: Predicate<SupaSetSchemaV1.Workout>?
        if let fromDate = currentFromDate {
            currentPredicate = #Predicate<SupaSetSchemaV1.Workout> { workout in
                workout.date >= fromDate
            }
        } else {
            currentPredicate = nil
        }
        
        // Create predicates for previous period
        let previousFromDate: Date?
        let previousToDate: Date?
        
        if let daysBack = period.daysBack {
            previousToDate = currentFromDate
            previousFromDate = Calendar.current.date(byAdding: .day, value: -daysBack, to: previousToDate!)
        } else {
            // For all time, we don't show a previous period
            previousFromDate = nil
            previousToDate = nil
        }
        
        let previousPredicate: Predicate<SupaSetSchemaV1.Workout>?
        if let fromDate = previousFromDate, let toDate = previousToDate {
            previousPredicate = #Predicate<SupaSetSchemaV1.Workout> { workout in
                workout.date >= fromDate && workout.date < toDate
            }
        } else {
            previousPredicate = nil
        }
        
        _currentWorkouts = Query(filter: currentPredicate, sort: [SortDescriptor(\.date, order: .reverse)])
        _previousWorkouts = Query(filter: previousPredicate, sort: [SortDescriptor(\.date, order: .reverse)])
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Training Balance by Body Region")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Text("Consise")
                    .font(.footnote)
                    .foregroundColor(labelColor)
                Toggle("", isOn: $showConsisedInfo)
                    .labelsHidden()
                    .padding(.trailing, 5)
            }
            .frame(maxWidth: .infinity)
            if currentPeriodData.isEmpty {
                Text("No workout data for this period")
                    .foregroundColor(labelColor)
                    .frame(maxWidth: .infinity, minHeight: 200)
            } else {
                VStack(spacing: 8) {
                    ZStack {
                        ComparativeRadarChartView(
                            currentData: currentPeriodData,
                            previousData: previousPeriodData,
                            selectedMuscle: $selectedMuscle,
                            currentPeriodColor: currentPeriodColor,
                            previousPeriodColor: previousPeriodColor,
                            currentPeriodFillColor: currentPeriodFillColor,
                            previousPeriodFillColor: previousPeriodFillColor,
                            gridLineColor: gridLineColor,
                            axisLineColor: axisLineColor,
                            labelColor: labelColor
                        )
                        .animation(.easeInOut(duration: 0.6), value: showConsisedInfo)
                        .frame(height: 300)
                    }
                    HStack(spacing: 8) {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(currentPeriodColor)
                                .frame(width: 8, height: 8)
                            Text("Current \(period.description)")
                                .font(.caption)
                        }
                        
                        if !previousPeriodData.isEmpty && period != .allTime {
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(previousPeriodColor)
                                    .frame(width: 8, height: 8)
                                Text("Previous \(period.description)")
                                    .font(.caption)
                            }
                        }
                    }
                    .padding(.top)
                    HStack {
                        if let selected = selectedMuscle,
                           let currentData = currentPeriodData.first(where: { $0.muscleGroup == selected }),
                           let previousData = previousPeriodData.first(where: { $0.muscleGroup == selected }) {
                            VStack(spacing: 4) {
                                Text(selected)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                HStack(spacing: 12) {
                                    VStack(alignment: .leading) {
                                        Text("Current: \(Int(currentData.totalVolume)) sets")
                                            .font(.caption)
                                            .foregroundColor(currentPeriodColor)
                                    }
                                    
                                    if period != .allTime {
                                        VStack(alignment: .leading) {
                                            Text("Previous: \(Int(previousData.totalVolume)) sets")
                                                .font(.caption)
                                                .foregroundColor(previousPeriodColor)
                                        }
                                    }
                                }
                            }
                            .transition(.opacity)
                            .animation(.easeInOut, value: selected)
                        } else {
                            Text("Tap a point to see details")
                                .font(.caption)
                                .foregroundColor(labelColor)
                                .padding(.vertical, 8)
                        }
                    }
                    .animation(.easeInOut(duration: 0.15), value: selectedMuscle)
                }
            }
        }
        .onAppear {
            calculateMuscleData()
        }
        .onChange(of: period) {
            calculateMuscleData()
        }
        .onChange(of: currentWorkouts) {
            calculateMuscleData()
        }
        .onChange(of: previousWorkouts) {
            calculateMuscleData()
        }
        .onChange(of: showConsisedInfo) {
            withAnimation(.easeInOut(duration: 0.25)) {
                // Clear selected muscle when toggle changes
                selectedMuscle = nil
            }
            calculateMuscleData()
        }
    }
    
    private func calculateMuscleData() {
        
        // Run the calculation on a background thread to avoid UI freezing
        Task {
            // Calculate data for current period
            let currentMuscleSets = await calculateMuscleSets(for: currentWorkouts)
            
            // Decide whether to group or use individual muscles
            let currentGroupedData: [String: Double]
            if !showConsisedInfo {
                // Convert MuscleGroup enum to string representation
                currentGroupedData = Dictionary(uniqueKeysWithValues:
                                                    currentMuscleSets.map { (muscle, value) in
                    (muscle.description, value)
                }
                )
            } else {
                // Group muscles by category
                currentGroupedData = groupMusclesByCategory(currentMuscleSets)
            }
            
            let currentCategories = currentGroupedData.map { category, setCount in
                MuscleGroupData(muscleGroup: category, totalVolume: setCount)
            }.sorted(by: { $0.muscleGroup < $1.muscleGroup })
            
            // Calculate data for previous period
            let previousMuscleSets = await calculateMuscleSets(for: previousWorkouts)
            
            // Apply the same grouping logic for consistency
            let previousGroupedData: [String: Double]
            if !showConsisedInfo {
                previousGroupedData = Dictionary(uniqueKeysWithValues:
                                                    previousMuscleSets.map { (muscle, value) in
                    (muscle.description, value)
                }
                )
            } else {
                previousGroupedData = groupMusclesByCategory(previousMuscleSets)
            }
            
            // Use the same categories as current period for consistency
            let previousCategories = currentCategories.map { current in
                MuscleGroupData(
                    muscleGroup: current.muscleGroup,
                    totalVolume: previousGroupedData[current.muscleGroup] ?? 0
                )
            }
            
            // Update on main thread
            await MainActor.run {
                self.currentPeriodData = currentCategories
                self.previousPeriodData = previousCategories
            }
        }
    }
    
    // Group individual muscles into broader categories
    private func groupMusclesByCategory(_ muscleData: [MuscleGroup: Double]) -> [String: Double] {
        var groupedData: [String: Double] = [
            "Back": 0,
            "Chest": 0,
            "Core": 0,
            "Shoulders": 0,
            "Arms": 0,
            "Legs": 0
        ]
        
        for (muscle, setCount) in muscleData {
            switch muscle {
            case .lats, .middleBack, .lowerBack, .traps:
                groupedData["Back"]! += setCount
                
            case .chest:
                groupedData["Chest"]! += setCount
                
            case .abdominals:
                groupedData["Core"]! += setCount
                
            case .shoulders:
                groupedData["Shoulders"]! += setCount
                
            case .biceps, .triceps, .forearms:
                groupedData["Arms"]! += setCount
                
            case .quadriceps, .hamstrings, .calves, .glutes, .abductors, .adductors:
                groupedData["Legs"]! += setCount
                
            case .neck:
                // Neck could go into shoulders or back, or be omitted
                groupedData["Shoulders"]! += setCount
            }
        }
        
        return groupedData
    }
    
    private func calculateMuscleSets(for workouts: [SupaSetSchemaV1.Workout]) async -> [MuscleGroup: Double] {
        var muscleSets: [MuscleGroup: Double] = [:]
        
        // Process each workout
        for workout in workouts {
            for exercise in workout.exercises {
                // Get exercise details from the view model
                guard let exerciseInfo = exerciseViewModel.exercises.first(where: { $0.id == exercise.exerciseID }) else {
                    continue
                }
                
                // Count the sets for this exercise
                let setCount = Double(exercise.sets.count)
                
                // Distribute the sets to primary and secondary muscles
                // Primary muscles get full count, secondary get half
                for muscle in exerciseInfo.primaryMuscles {
                    muscleSets[muscle, default: 0] += setCount
                }
                
                for muscle in exerciseInfo.secondaryMuscles {
                    muscleSets[muscle, default: 0] += setCount * 0.5
                }
            }
        }
        
        return muscleSets
    }
}

// New comparative radar chart
struct ComparativeRadarChartView: View {
    let currentData: [MuscleGroupData]
    let previousData: [MuscleGroupData]
    @Binding var selectedMuscle: String?
    
    // Color properties for customization
    let currentPeriodColor: Color
    let previousPeriodColor: Color
    let currentPeriodFillColor: Color
    let previousPeriodFillColor: Color
    let gridLineColor: Color
    let axisLineColor: Color
    let labelColor: Color
    
    private var maxVolume: Double {
        let currentMax = currentData.map(\.totalVolume).max() ?? 0
        let previousMax = previousData.map(\.totalVolume).max() ?? 0
        return max(currentMax, previousMax, 1) // Ensure we don't divide by zero
    }
    
    private var normalizedCurrentData: [MuscleGroupData] {
        currentData.map {
            MuscleGroupData(
                muscleGroup: $0.muscleGroup,
                totalVolume: $0.totalVolume / maxVolume
            )
        }
    }
    
    private var normalizedPreviousData: [MuscleGroupData] {
        previousData.map {
            MuscleGroupData(
                muscleGroup: $0.muscleGroup,
                totalVolume: $0.totalVolume / maxVolume
            )
        }
    }
    
    // Helper function to calculate angle for a given index
    private func angleForIndex(_ index: Int, totalCount: Int) -> Double {
        return (2 * .pi * Double(index) / Double(totalCount)) - (.pi / 2)
    }
    
    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let minDimension = min(geometry.size.width, geometry.size.height)
            let radius = minDimension * 0.4
            
            // Background grid
            ZStack {
                // Grid circles
                ForEach(0..<5, id: \.self) { index in
                    let scale = Double(index + 1) / 5.0
                    RadarGridCircle(
                        radius: radius,
                        scale: scale,
                        isOutermost: index == 4,
                        gridLineColor: gridLineColor
                    )
                }
                
                // Axis lines and labels
                ForEach(0..<currentData.count, id: \.self) { index in
                    let angle = angleForIndex(index, totalCount: currentData.count)
                    
                    RadarAxisLine(
                        center: center,
                        radius: radius,
                        angle: angle,
                        axisLineColor: axisLineColor
                    )
                    
                    RadarAxisLabel(
                        center: center,
                        radius: radius,
                        angle: angle,
                        label: currentData[index].muscleGroup,
                        labelColor: labelColor
                    )
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.25), value: currentData.count)
                }
                
                // Draw previous period radar shape first (behind current)
                if !previousData.isEmpty {
                    RadarShape(dataPoints: normalizedPreviousData, center: center, radius: radius)
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [previousPeriodFillColor, Color.clear]),
                            startPoint: .top,
                            endPoint: .bottom
                        ))
                        .animation(.easeInOut(duration: 0.3), value: normalizedPreviousData)
                        .opacity(selectedMuscle != nil ? 0.5 : 1)
                    
                    RadarShape(dataPoints: normalizedPreviousData, center: center, radius: radius)
                        .stroke(previousPeriodColor, lineWidth: 1.5)
                        .animation(.easeInOut(duration: 0.3), value: normalizedPreviousData)
                        .opacity(selectedMuscle != nil ? 0.5 : 1)
                }
                
                // Draw current period radar shape
                RadarShape(dataPoints: normalizedCurrentData, center: center, radius: radius)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [currentPeriodFillColor, Color.clear]),
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .animation(.easeInOut(duration: 0.3), value: normalizedCurrentData)
                    .opacity(selectedMuscle != nil ? 0.5 : 1)
                
                RadarShape(dataPoints: normalizedCurrentData, center: center, radius: radius)
                    .stroke(currentPeriodColor, lineWidth: 2)
                    .animation(.easeInOut(duration: 0.3), value: normalizedCurrentData)
                    .opacity(selectedMuscle != nil ? 0.5 : 1)
                
                // Current period data points
                ForEach(0..<normalizedCurrentData.count, id: \.self) { index in
                    let dataPoint = normalizedCurrentData[index]
                    let angle = angleForIndex(index, totalCount: normalizedCurrentData.count)
                    
                    RadarDataPoint(
                        center: center,
                        radius: radius,
                        angle: angle,
                        value: dataPoint.totalVolume,
                        muscleGroup: dataPoint.muscleGroup,
                        isSelected: selectedMuscle == dataPoint.muscleGroup,
                        anyPointSelected: selectedMuscle != nil,
                        color: currentPeriodColor
                    ) {
                        // Toggle selection
                        if selectedMuscle == dataPoint.muscleGroup {
                            selectedMuscle = nil
                        } else {
                            selectedMuscle = dataPoint.muscleGroup
                        }
                    }
                    .transition(.scale.combined(with: .opacity))
                }
                
                // Previous period data points
                if !previousData.isEmpty {
                    ForEach(0..<normalizedPreviousData.count, id: \.self) { index in
                        let dataPoint = normalizedPreviousData[index]
                        let angle = angleForIndex(index, totalCount: normalizedPreviousData.count)
                        
                        if dataPoint.totalVolume > 0 {
                            RadarDataPoint(
                                center: center,
                                radius: radius,
                                angle: angle,
                                value: dataPoint.totalVolume,
                                muscleGroup: dataPoint.muscleGroup,
                                isSelected: selectedMuscle == dataPoint.muscleGroup, anyPointSelected: selectedMuscle != nil,
                                color: previousPeriodColor
                            ) {
                                // Toggle selection
                                if selectedMuscle == dataPoint.muscleGroup {
                                    selectedMuscle = nil
                                } else {
                                    selectedMuscle = dataPoint.muscleGroup
                                }
                            }
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}
// Update RadarDataPoint to accept color
struct RadarDataPoint: View {
    let center: CGPoint
    let radius: CGFloat
    let angle: Double
    let value: Double
    let muscleGroup: String
    let isSelected: Bool
    let anyPointSelected: Bool
    let color: Color
    let action: () -> Void
    let circleFrame: CGFloat = 8
    var body: some View {
        let position = pointPosition()
        
        Circle()
            .fill(color)
            .frame(width: circleFrame, height: circleFrame)
            .position(position)
            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: circleFrame, height: circleFrame)
                    .opacity(isSelected ? 1 : 0)
                    .position(position)
            )
            .opacity(anyPointSelected ? (isSelected ? 1 : 0.5) : 1)
            .onTapGesture(perform: action)
    }
    
    private func pointPosition() -> CGPoint {
        return CGPoint(
            x: center.x + radius * CGFloat(value) * CGFloat(cos(angle)),
            y: center.y + radius * CGFloat(value) * CGFloat(sin(angle))
        )
    }
}

// Helper structs for reducing complexity
struct RadarGridCircle: View {
    let radius: CGFloat
    let scale: Double
    let isOutermost: Bool
    let gridLineColor: Color
    
    var body: some View {
        Circle()
            .stroke(gridLineColor, lineWidth: isOutermost ? 1.5 : 0.5)
            .frame(width: radius * 2 * scale, height: radius * 2 * scale)
    }
}

struct RadarAxisLine: View {
    let center: CGPoint
    let radius: CGFloat
    let angle: Double
    let axisLineColor: Color
    
    var body: some View {
        Path { path in
            path.move(to: center)
            let endpoint = pointForAngle(angle: angle, value: 1.0)
            path.addLine(to: endpoint)
        }
        .stroke(axisLineColor, lineWidth: 0.5)
    }
    
    private func pointForAngle(angle: Double, value: Double) -> CGPoint {
        return CGPoint(
            x: center.x + radius * CGFloat(value) * CGFloat(cos(angle)),
            y: center.y + radius * CGFloat(value) * CGFloat(sin(angle))
        )
    }
}

struct RadarAxisLabel: View {
    let center: CGPoint
    let radius: CGFloat
    let angle: Double
    let label: String
    let labelColor: Color
    
    /// Adjust alignment based on angle.
    private var textAlignment: Alignment {
        let cosine = cos(angle)
        if cosine > 0.3 {
            return .leading
        } else if cosine < -0.3 {
            return .trailing
        } else {
            return .center
        }
    }
    
    var body: some View {
        Text(label.capitalized)
            .font(.system(size: 10))
            .foregroundColor(labelColor)
            .frame(width: 70)
            .position(
                x: center.x + (radius + 30) * CGFloat(cos(angle)),
                y: center.y + (radius + 30) * CGFloat(sin(angle))
            )
    }
}

// Shape to draw the radar pattern - simplified with helper functions
struct RadarShape: Shape {
    let dataPoints: [MuscleGroupData]
    let center: CGPoint
    let radius: CGFloat
    
    // Make shape animatable
    var animatableData: Double {
        get { 1.0 }  // Dummy value
        set { }      // Required but not used
    }
    
    // Calculate a point for a given angle and value
    private func pointForAngleAndValue(angle: Double, value: Double) -> CGPoint {
        return CGPoint(
            x: center.x + radius * CGFloat(value) * CGFloat(cos(angle)),
            y: center.y + radius * CGFloat(value) * CGFloat(sin(angle))
        )
    }
    
    // Calculate angle for index
    private func angleForIndex(_ index: Int, totalCount: Int) -> Double {
        return (2 * .pi * Double(index) / Double(totalCount)) - (.pi / 2)
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        guard dataPoints.count >= 3 else {
            // Need at least 3 points for a polygon
            return path
        }
        
        // First point
        let firstAngle = angleForIndex(0, totalCount: dataPoints.count)
        let firstPoint = pointForAngleAndValue(
            angle: firstAngle,
            value: dataPoints[0].totalVolume
        )
        path.move(to: firstPoint)
        
        // Remaining points
        for index in 1..<dataPoints.count {
            let angle = angleForIndex(index, totalCount: dataPoints.count)
            let point = pointForAngleAndValue(
                angle: angle,
                value: dataPoints[index].totalVolume
            )
            path.addLine(to: point)
        }
        
        path.closeSubpath()
        return path
    }
}


// MARK: - Preview
#Preview {
    let preview = PreviewContainer.preview
    MuscleRadarChartView(
        period: .month,
        currentPeriodColor: .blue,
        previousPeriodColor: .orange,
        currentPeriodFillColor: .blue.opacity(0.3),
        previousPeriodFillColor: .orange.opacity(0.3)
    )
    .frame(height: 400)
    .padding()
    .environment(preview.viewModel)
    .modelContainer(preview.container)
}
