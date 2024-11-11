//
//  SupaSetWidget.swift
//  SupaSetWidget
//
//  Created by Rishi Garg on 11/8/24.
//

import WidgetKit
import SwiftUI
import ActivityKit

import WidgetKit
import SwiftUI
import ActivityKit

struct SupaSetWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WorkoutAttributes.self) { context in
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "figure.run")
                        .foregroundStyle(.green)
                    Text("Workout in Progress")
                        .font(.headline)
                    Spacer()
                    Text(context.state.workoutStartTime, style: .timer)
                        .monospacedDigit()
                }
                .padding(.horizontal)
                
                // Current Exercise
                VStack(alignment: .leading, spacing: 4) {
                    //current exercise
                    Text("Current Exercise")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(context.state.currentExerciseName)
                        .font(.title2)
                        .bold()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Set")
                            .foregroundStyle(.secondary)
                        Text("\(context.state.setNumber)")
                            .bold()
                    }
                    .font(.subheadline)
                    
                    ProgressView(value: Double(context.state.setNumber), total: 5)
                        .tint(.green)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
            .frame(maxWidth: .infinity)
            
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded Dynamic Island
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "figure.run")
                        .foregroundStyle(.green)
                }
                
                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.currentExerciseName)
                        .font(.system(.headline, weight: .bold))
                        .lineLimit(1)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Set \(context.state.setNumber)")
                        .font(.system(.subheadline, weight: .semibold))
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Label {
                            Text(context.state.workoutStartTime, style: .timer)
                                .monospacedDigit()
                        } icon: {
                            Image(systemName: "timer")
                        }
                        .font(.system(.body, weight: .medium))
                        
                        Spacer()
                        
                        Label("\(context.state.setNumber)/5", systemImage: "chart.bar.fill")
                            .font(.system(.body, weight: .medium))
                    }
                    .padding(.top, 4)
                }
            } compactLeading: {
                // Compact leading view
                Image(systemName: "figure.run")
                    .foregroundStyle(.green)
            } compactTrailing: {
                // Compact trailing view
                Text("Set \(context.state.setNumber)")
                    .font(.caption2)
                    .bold()
            } minimal: {
                // Minimal view
                Image(systemName: "figure.run")
                    .foregroundStyle(.green)
            }
        }
    }
}
