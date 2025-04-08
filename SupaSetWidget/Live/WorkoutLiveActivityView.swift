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
            // Top Row: Workout Name and Timer
            HStack {
                Label(context.state.workoutName, systemImage: "dumbbell.fill")
                    .font(.callout.bold())
                Spacer()
                Text("00:00:00")
                    .hidden()
                    .overlay(alignment: .leading){
                        Text(context.attributes.startTime, style: .timer)
                            .multilineTextAlignment(.trailing)
                    }
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
                        .padding(.vertical, 4)
                        .background(Color.theme.secondary.opacity(0.5))
                        .clipShape(Capsule())
                    
                    if context.state.type != .working {
                        Text(context.state.type.description)
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
                        Image(systemName: "minus")
                            .foregroundStyle(Color.background)
                            .padding(7)
                    }
                    .frame(maxHeight: .infinity)
                    .buttonStyle(PlainButtonStyle())
                    .background(Color.theme.accent)
                    .clipShape(.circle)
                    
                    Text("\(Int(context.state.weight))lb")
                        .font(.headline.monospacedDigit())
                        .frame(width: 65, alignment: .center)
                    
                    Button(intent: IncrementWeightIntent(workoutId: context.attributes.workoutId)) {
                        Image(systemName: "plus")
                            .foregroundStyle(Color.background)
                            .padding(7)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .background(Color.theme.accent)
                    .clipShape(.circle)
                }
                
                // Reps Controls
                HStack(spacing: 2) {
                    Button(intent: DecrementRepsIntent(workoutId: context.attributes.workoutId)) {
                        Image(systemName: "minus")
                            .foregroundStyle(Color.background)
                            .padding(7)
                        
                    }
                    .frame(maxHeight: .infinity)
                    .buttonStyle(PlainButtonStyle())
                    .background(Color.theme.accent)
                    .clipShape(.circle)
                    
                    Text("\(context.state.targetReps) reps")
                        .font(.headline.monospacedDigit())
                        .frame(width: 65, alignment: .center)
                    
                    Button(intent: IncrementRepsIntent(workoutId: context.attributes.workoutId)) {
                        Image(systemName: "plus")
                            .foregroundStyle(Color.background)
                            .padding(7)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .background(Color.theme.accent)
                    .clipShape(.circle)
                }
            }
            .frame(maxHeight: .infinity)
            .padding(.vertical, 4)
            
            // Complete Set Button
            Button(intent: CompleteSetIntent(workoutId: context.attributes.workoutId)) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Complete Set")
                }
                .padding(.vertical, 2)
                .frame(maxWidth: .infinity)
            }
            .padding(5)
            .buttonStyle(PlainButtonStyle())
            .background(Color.theme.secondary)
            .clipShape(.capsule)
        }
        .foregroundStyle(Color.theme.text)
        .padding(12)
    }
}
