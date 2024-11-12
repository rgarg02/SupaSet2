//
//  SupaSetWidget.swift
//  SupaSetWidget
//
//  Created by Rishi Garg on 11/8/24.
//

import WidgetKit
import SwiftUI
import ActivityKit

struct SupaSetWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WorkoutAttributes.self) { context in
            WorkoutLiveActivityView(context: context)
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

