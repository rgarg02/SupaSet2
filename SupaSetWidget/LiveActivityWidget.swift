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
                .background(Color.theme.background)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.state.currentExerciseName)
                        .font(.headline)
                        .lineLimit(1)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Set \(context.state.currentSetNumber)/\(context.state.totalSets)")
                        .font(.callout)
                }
                
                DynamicIslandExpandedRegion(.center) {
                    HStack {
                        Text("\(Int(context.state.weight))lbs")
                        Text("×")
                        Text("\(context.state.targetReps)")
                    }
                    .font(.title3)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Button("Previous") {
                            // Previous exercise action
                        }
                        
                        Spacer()
                        
                        Button("Complete Set") {
                            // Complete set action
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Spacer()
                        
                        Button("Next") {
                            // Next exercise action
                        }
                    }
                    .padding(.top, 8)
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
        workoutName: "Upper Body Workout",
        startTime: Date(timeInterval: -100000, since: Date())
    )
    
    static let previewRegularSet = ContentState(
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
