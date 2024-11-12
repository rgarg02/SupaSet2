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
        VStack(spacing: 5) {
            HStack {
                Text(context.attributes.workoutName)
                    .font(.headline)
                Spacer()
                Text(context.attributes.startTime, style: .timer)
                    .monospacedDigit()
            }
            
            VStack(spacing: 4) {
                HStack {
                Text("\(context.state.currentExerciseName)")
                    .font(.title2.bold())
                    Text("Set \(context.state.currentSetNumber)/\(context.state.totalSets)")
                    if context.state.isWarmupSet {
                        Text("(Warm-up)")
                            .foregroundStyle(.secondary)
                    }
                }
                
                HStack {
                    Text("\(Int(context.state.weight))lbs")
                    Text("×")
                    Text("\(context.state.targetReps) reps")
                }
                .font(.title3)
                
                Text("Exercise \(context.state.exerciseNumber)/\(context.state.totalExercises)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            HStack {
                if (context.state.exerciseNumber > 1) {
                    Button(intent: PreviousExerciseIntent(workoutId: context.attributes.workoutId)) {
                        Label("Previous", systemImage: "chevron.backward")
                    }
                    .buttonStyle(.bordered)
                    
                    Spacer()
                }
                Button(action: {
                    // Complete set action
                }) {
                    Text("Complete Set")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                if (context.state.exerciseNumber < context.state.totalExercises){
                    Spacer()
                    
                    Button(intent: NextExerciseIntent(workoutId: context.attributes.workoutId)) {
                        Label("Next", systemImage: "chevron.forward")
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding()
    }
}
