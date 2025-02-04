//
//  WorkoutFinishedVIew.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/29/25.
//

import SwiftUI
import Charts
import SceneKit

struct WorkoutFinishedView: View {
    var workout: Workout
    @State private var showContent = false
    @State private var animatedStats = false
    @State private var animatedCharts = false
    @State private var animatedExercises = false
    @State private var showConfetti = false
    @State private var sceneView = SCNView()
    @Namespace private var animationNamespace
    @Environment(ExerciseViewModel.self) private var viewModel
    // Stats calculations
    // Computed properties for statistics
    private var duration: TimeInterval { workout.duration }
    private var totalVolume: Double { workout.totalVolume }
    private var totalSets: Int { workout.exercises.reduce(0) { $0 + $1.sets.count } }
    private var totalReps: Int { workout.exercises.flatMap { $0.sets.map { $0.reps } }.reduce(0, +) }
    private var avgReps: Double { totalSets > 0 ? Double(totalReps) / Double(totalSets) : 0 }
    private var maxWeight: Double { workout.exercises.flatMap { $0.sets.map { $0.weight } }.max() ?? 0 }
    private var averageWeightPerSet: Double {
        guard totalSets > 0 else { return 0 }
        return totalVolume / Double(totalSets)
    }
    
    private var allSets: [ExerciseSet] {
        workout.exercises
            .sorted(by: { $0.order < $1.order })
            .flatMap { $0.sets.sorted(by: { $0.order < $1.order }) }
    }
    
    private var durationString: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: workout.duration) ?? ""
    }
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ZStack{
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                    MuscleIntensityView(workout: workout)
                        .opacity(animatedStats ? 1 : 0)
                        .scaleEffect(animatedStats ? 1 : 0.8)
                    statsGrid
                        .opacity(animatedStats ? 1 : 0)
                        .scaleEffect(animatedStats ? 1 : 0.8)
                    volumeChart
                        .opacity(animatedCharts ? 1 : 0)
                        .offset(x: animatedCharts ? 0 : -50)
                    
                    weightProgressionChart
                        .opacity(animatedCharts ? 1 : 0)
                        .offset(x: animatedCharts ? 0 : 50)
                    
                    exerciseSummary
                        .opacity(animatedExercises ? 1 : 0)
                }
                .padding()
            }
            if showConfetti {
                ConfettiView()
                    .allowsHitTesting(false)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Workout Summary")
        .onAppear {
            // Start animations after short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeOut(duration: 2)) {
                    showConfetti = true
                }
            }
            withAnimation(.easeInOut(duration: 0.4)) {
                showContent = true
            }
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
                animatedStats = true
            }
            
            withAnimation(.easeInOut(duration: 0.4).delay(0.4)) {
                animatedCharts = true
            }
            
            withAnimation(.easeInOut(duration: 0.4).delay(0.6)) {
                animatedExercises = true
            }
        }
        .background(Color.theme.background)
        .navigationTitle("Workout Summary")
    }
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(workout.name)
                    .font(.title.bold())
                    .foregroundStyle(Color.theme.text)
                
                Text(workout.date.formatted(date: .abbreviated, time: .omitted))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("Duration")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(durationString)
                    .foregroundStyle(Color.theme.text)
                    .font(.title3.bold())
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .matchedGeometryEffect(id: "header", in: animationNamespace)
    }
    
    private var statsGrid: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            StatCardFinished(
                title: "Total Volume",
                value: workout.totalVolume,
                unit: "kg",
                gradient: .purpleGradient
            )
            
            StatCardFinished(
                title: "Average Reps",
                value: avgReps,
                unit: "reps",
                gradient: .orangeGradient
            )
            
            StatCardFinished(
                title: "Max Weight",
                value: maxWeight,
                unit: "kg",
                gradient: .blueGradient
            )
            
            StatCardFinished(
                title: "Total Sets",
                value: Double(totalSets),
                unit: "sets",
                gradient: .greenGradient
            )
        }
    }
    
    private var volumeChart: some View {
        VStack(alignment: .leading) {
            Text("Volume by Exercise")
                .font(.headline)
                .padding(.horizontal)
            
            Chart {
                ForEach(workout.exercises.sorted(by: { $0.totalVolume > $1.totalVolume })) { exercise in
                    BarMark(
                        x: .value("Volume", exercise.totalVolume),
                        y: .value("Exercise", exercise.exerciseID)
                    )
                    .foregroundStyle(by: .value("Exercise", exercise.exerciseID))
                }
            }
            .chartLegend(.hidden)
            .chartXAxisLabel("Total Volume (kg)")
            .frame(height: 200)
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
    }
    
    private var weightProgressionChart: some View {
        VStack(alignment: .leading) {
            Text("Weight Progression")
                .font(.headline)
                .padding(.horizontal)
            
            Chart {
                ForEach(Array(allSets.enumerated()), id: \.offset) { index, set in
                    LineMark(
                        x: .value("Set", index + 1),
                        y: .value("Weight", set.weight)
                    )
                    .foregroundStyle(.blue)
                }
            }
            .chartXAxisLabel("Set Number")
            .chartYAxisLabel("Weight (kg)")
            .frame(height: 200)
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
    }
    
    private var exerciseSummary: some View {
        VStack(alignment: .leading) {
            Text("Exercise Summary")
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(Array(workout.exercises.enumerated()), id: \.element.id) { index, exercise in
                HStack {
                    Text(viewModel.getExerciseName(for: exercise.exerciseID))
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text("\(exercise.sets.count) sets")
                        .foregroundColor(.secondary)
                    
                    Text("\(exercise.totalVolume.formatted()) kg")
                        .bold()
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
                .opacity(animatedExercises ? 1 : 0)
                .offset(y: animatedExercises ? 0 : 20)
                .animation(
                    .easeOut(duration: 0.3).delay(Double(index) * 0.1),
                    value: animatedExercises
                )
            }
        }
    }
}
// Updated gradient definitions
extension LinearGradient {
    static let purpleGradient = LinearGradient(
        colors: [Color.theme.primary, Color.theme.primarySecond],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let orangeGradient = LinearGradient(
        colors: [Color.theme.accent, Color.theme.primary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let blueGradient = LinearGradient(
        colors: [Color.theme.secondary, Color.theme.secondarySecond],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let greenGradient = LinearGradient(
        colors: [Color.theme.secondary, Color.theme.secondarySecond],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

#Preview {
    let preview = PreviewContainer.preview
    WorkoutFinishedView(workout: preview.completedWorkouts.first!)
        .modelContainer(preview.container)
        .environment(preview.viewModel)
}
