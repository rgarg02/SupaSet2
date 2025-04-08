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
                .background(Color.theme.background.gradient)
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
                            .padding(.top, 5)
                        HStack{
                            Button(intent: DecrementWeightIntent(workoutId: context.attributes.workoutId)) {
                                Image(systemName: "minus")
                                    .foregroundStyle(Color.background)
                                    .padding(7)
                            }
                            .frame(maxHeight: .infinity)
                            .buttonStyle(PlainButtonStyle())
                            .background(Color.theme.accent)
                            .clipShape(.circle)
                            
                            Button(intent: IncrementWeightIntent(workoutId: context.attributes.workoutId)) {
                                Image(systemName: "plus")
                                    .foregroundStyle(Color.background)
                                    .padding(7)
                            }
                            .frame(maxHeight: .infinity)
                            .buttonStyle(PlainButtonStyle())
                            .background(Color.theme.accent)
                            .clipShape(.circle)
                        }
                    }
                    .foregroundStyle(Color.theme.text)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(spacing: 5){
                        Text("00:00:00")
                            .hidden()
                            .overlay(alignment: .leading){
                                Text(context.attributes.startTime, style: .timer)
                                    .multilineTextAlignment(.leading)
                            }
                            .frame(height: 10)
                        
                        Text("\(Int(context.state.targetReps)) reps")
                            .font(.headline.monospacedDigit())
                            .frame(width: 65, alignment: .center)
                            .padding(.top, 5)
                        HStack{
                            Button(intent: DecrementRepsIntent(workoutId: context.attributes.workoutId)) {
                                Image(systemName: "minus")
                                    .foregroundStyle(Color.background)
                                    .padding(7)
                            }
                            .frame(maxHeight: .infinity)
                            .buttonStyle(PlainButtonStyle())
                            .background(Color.theme.accent)
                            .clipShape(.circle)
                            
                            Button(intent: IncrementRepsIntent(workoutId: context.attributes.workoutId)) {
                                Image(systemName: "plus")
                                    .foregroundStyle(Color.background)
                                    .padding(7)
                                    
                            }
                            .frame(maxHeight: .infinity)
                            .buttonStyle(PlainButtonStyle())
                            .background(Color.theme.accent)
                            .clipShape(.circle)
                        }
                    }
                    .foregroundStyle(Color.theme.text)
                }
                
                DynamicIslandExpandedRegion(.center) {
                    VStack{
                        Text(context.state.currentExerciseName)
                            .font(.title3.bold())
                            .lineLimit(1)
                        Text("Set \(context.state.currentSetNumber)/\(context.state.totalSets)")
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.theme.secondary.opacity(0.5))
                            .clipShape(Capsule())
                    }
                    .foregroundStyle(Color.theme.text)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    Button(intent: CompleteSetIntent(workoutId: context.attributes.workoutId)) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Complete Set")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 2)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(5)
                    .background(Color.theme.secondary)
                    .clipShape(.capsule)
                    .foregroundStyle(Color.theme.text)
                }
            } compactLeading: {
                Image(systemName: "dumbbell.fill")
                    .font(.callout.bold())
            } compactTrailing: {
                Text("0:00:00")
                    .hidden()
                    .overlay{
                        Text(context.attributes.startTime,
                             style: .timer)
                        .contentTransition(.numericText(countsDown: true))
                        .multilineTextAlignment(.center)
                    }
            } minimal: {
                Image(systemName: "dumbbell.fill")
                    .font(.callout.bold())
                    .frame(height: 10)
            }
            .keylineTint(Color.theme.accent)
        }
    }
}
