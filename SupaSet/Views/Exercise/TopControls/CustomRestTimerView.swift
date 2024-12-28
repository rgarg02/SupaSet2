//
//  CustomRestTimerView.swift
//  SupaSet
//
//  Created by Rishi Garg on 12/17/24.
//

import SwiftUI
import SwiftData
struct RestTimerView: View {
    @Bindable var exerciseDetail: ExerciseDetail
    @State private var isAutoRestEnabled: Bool = false
    @State private var minutes: Int = 0
    @State private var seconds: Int = 0
    
    var body: some View {
        VStack {
            Form {
                Section {
                    Toggle("Auto Rest Timer", isOn: $isAutoRestEnabled)
                }
                if isAutoRestEnabled {
                    Section("Rest Duration") {
                        HStack(spacing: 0) {
                            Picker("Minutes", selection: $minutes) {
                                ForEach(0..<11) { minute in
                                    Text("\(minute)")
                                        .tag(minute)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: 100)
                            
                            Text("min")
                                .font(.body)
                            
                            Picker("Seconds", selection: $seconds) {
                                ForEach(0..<60) { second in
                                    Text(String(format: "%02d", second))
                                        .tag(second)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: 100)
                            
                            Text("sec")
                                .font(.body)
                        }
                    }
                }
            }
            .foregroundColor(.theme.text)
        }
        .onChange(of: isAutoRestEnabled) { _, newValue in
            updateExerciseDetail(enabled: newValue)
        }
        .onChange(of: minutes) { _, _ in
            updateTimer()
        }
        .onChange(of: seconds) { _, _ in
            updateTimer()
        }
    }
    
    
    private func updateExerciseDetail(enabled: Bool) {
        if enabled {
            exerciseDetail.autoRestTimer = TimeInterval(minutes * 60 + seconds)
        } else {
            exerciseDetail.autoRestTimer = 0
            minutes = 0
            seconds = 0
        }
    }
    
    private func updateTimer() {
        exerciseDetail.autoRestTimer = TimeInterval(minutes * 60 + seconds)
    }
}
