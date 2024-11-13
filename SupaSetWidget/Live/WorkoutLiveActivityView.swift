//
//  WorkoutLiveActivityView.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/11/24.
//


import SwiftUI
import WidgetKit
import SwiftData


// MARK: - Live Activity View
struct WorkoutLiveActivityView: View {
    let context: ActivityViewContext<WorkoutAttributes>
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(.ultraThinMaterial)
            
            VStack(spacing: 5) {
                // Top Row: Workout Name and Timer
                HStack {
                    Label(context.attributes.workoutName, systemImage: "dumbbell.fill")
                        .font(.callout.bold())
                    Spacer()
                    Text(context.attributes.startTime, style: .timer)
                        .font(.callout.monospacedDigit())
                }
                .foregroundStyle(.secondary)
                
                // Exercise Name and Progress
                HStack(alignment: .center) {
                    Text(context.state.currentExerciseName)
                        .font(.title3.bold())
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // Progress Pills
                    HStack(spacing: 4) {
                        Text("Set \(context.state.currentSetNumber)/\(context.state.totalSets)")
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.secondary.opacity(0.15))
                            .clipShape(Capsule())
                        
                        if context.state.isWarmupSet {
                            Text("Warm-up")
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(.orange.opacity(0.15))
                                .foregroundStyle(.orange)
                                .clipShape(Capsule())
                        }
                    }
                    .font(.caption.bold())
                }
                
                // Weight and Reps Controls
                HStack(spacing: 16) {
                    // Weight Controls
                    HStack(spacing: 2) {
                        Button(intent: DecrementWeightIntent(workoutId: context.attributes.workoutId)) {
                            Image(systemName: "minus.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        
                        Text("\(Int(context.state.weight))lb")
                            .font(.headline.monospacedDigit())
                            .frame(width: 65, alignment: .center)
                        
                        Button(intent: IncrementWeightIntent(workoutId: context.attributes.workoutId)) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    // Reps Controls
                    HStack(spacing: 2) {
                        Button(intent: DecrementRepsIntent(workoutId: context.attributes.workoutId)) {
                            Image(systemName: "minus.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        
                        Text("\(context.state.targetReps) reps")
                            .font(.headline.monospacedDigit())
                            .frame(width: 65, alignment: .center)
                        
                        Button(intent: IncrementRepsIntent(workoutId: context.attributes.workoutId)) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.vertical, 4)
                
                // Complete Set Button
                Button(intent: CompleteSetIntent(workoutId: context.attributes.workoutId)) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Complete Set")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 2)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
            }
            .padding(12)
        }
    }
}
// MARK: - Live Activity Previews
#Preview("Live Activity - Regular Set", as: .content, using: WorkoutAttributes.previewAttributes) {
    LiveActivityWidget()
} contentStates: {
    WorkoutAttributes.previewRegularSet
}

#Preview("Live Activity - Warmup Set", as: .content, using: WorkoutAttributes.previewAttributes) {
    LiveActivityWidget()
} contentStates: {
    WorkoutAttributes.previewWarmupSet
}

#Preview("Live Activity - Middle Exercise", as: .content, using: WorkoutAttributes.previewAttributes) {
    LiveActivityWidget()
} contentStates: {
    WorkoutAttributes.previewMiddleExercise
}
