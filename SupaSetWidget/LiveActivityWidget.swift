//
//  SupaSetWidget.swift
//  SupaSetWidget
//
//  Created by Rishi Garg on 11/8/24.
//

import WidgetKit
import SwiftUI
import ActivityKit
import SwiftData

struct LiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WorkoutAttributes.self) { context in
            WorkoutLiveActivityView(context: context)
                .containerBackground(.fill.tertiary, for: .widget)
                .background(Color.theme.primary)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(spacing: 5){
                        Image(systemName: "dumbbell.fill")
                            .font(.callout.bold())
                            .padding(.leading)
                            .frame(height: 10)
                        
                        Text("\(Int(context.state.weight))lb")
                            .font(.headline.monospacedDigit())
                            .frame(width: 65, alignment: .center)
                        HStack{
                            Button(intent: DecrementWeightIntent(workoutId: context.attributes.workoutId)) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                            
                            Button(intent: IncrementWeightIntent(workoutId: context.attributes.workoutId)) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(spacing: 5){
                        Text("00:00")
                            .padding(.trailing)
                            .font(.callout.bold())
                            .frame(height: 10)
                        
                        Text("\(Int(context.state.targetReps)) reps")
                            .font(.headline.monospacedDigit())
                            .frame(width: 65, alignment: .center)
                        HStack{
                            Button(intent: DecrementRepsIntent(workoutId: context.attributes.workoutId)) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                            
                            Button(intent: IncrementRepsIntent(workoutId: context.attributes.workoutId)) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                
                DynamicIslandExpandedRegion(.center) {
                    VStack{
                        Text(context.state.currentExerciseName)
                            .font(.title3.bold())
                            .lineLimit(1)
                        Text("Set \(context.state.currentSetNumber)/\(context.state.totalSets)")
                            .padding(.horizontal, 6)
                            .background(Color.theme.secondary.opacity(0.4))
                            .clipShape(Capsule())
                    }
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    Button(intent: CompleteSetIntent(workoutId: context.attributes.workoutId)) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Complete Set")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 2)
                    }
                }
            } compactLeading: {
                Text("\(context.state.currentSetNumber)/\(context.state.totalSets)")
            } compactTrailing: {
                Text("\(context.state.weight, specifier: "%.0f")×\(context.state.targetReps)")
            } minimal: {
                Text("\(context.state.currentSetNumber)")
            }
        }
    }
}


#if DEBUG
// MARK: - Preview Content States
extension WorkoutAttributes {
    static let previewAttributes = WorkoutAttributes(
        workoutId: UUID().uuidString,
        startTime: Date(timeInterval: -1000, since: Date())
    )
    
    static let previewRegularSet = ContentState(
        workoutName: "Upper Body Workout",
        currentExerciseName: "Bench Press",
        currentSetNumber: 2,
        totalSets: 4,
        weight: 135.0,
        targetReps: 8,
        isWarmupSet: false,
        exerciseNumber: 1,
        totalExercises: 5
    )
    
    static let previewWarmupSet = ContentState(
        workoutName: "Upper Body Workout",
        currentExerciseName: "Barbell Squats",
        currentSetNumber: 1,
        totalSets: 3,
        weight: 95.0,
        targetReps: 10,
        isWarmupSet: true,
        exerciseNumber: 1,
        totalExercises: 6
    )
    
    static let previewMiddleExercise = ContentState(
        workoutName: "Upper Body Workout",
        currentExerciseName: "Shoulder Press",
        currentSetNumber: 2,
        totalSets: 4,
        weight: 95.0,
        targetReps: 12,
        isWarmupSet: false,
        exerciseNumber: 3,
        totalExercises: 5
    )
}

// MARK: - Dynamic Island Previews
#Preview("Dynamic Island Expanded", as: .dynamicIsland(.expanded), using: WorkoutAttributes.previewAttributes) {
    LiveActivityWidget()
} contentStates: {
    WorkoutAttributes.previewRegularSet
}

#Preview("Dynamic Island Minimal", as: .dynamicIsland(.minimal), using: WorkoutAttributes.previewAttributes) {
    LiveActivityWidget()
} contentStates: {
    WorkoutAttributes.previewRegularSet
}

#Preview("Dynamic Island Compact", as: .dynamicIsland(.compact), using: WorkoutAttributes.previewAttributes) {
    LiveActivityWidget()
} contentStates: {
    WorkoutAttributes.previewRegularSet
}
#endif
