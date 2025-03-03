
import SwiftUI
import SwiftData

struct RestTimerView: View {
    @Bindable var exerciseDetail: ExerciseDetail
    @State private var minutes: Int = 0
    @State private var seconds: Int = 0
    @State private var isEnabled: Bool = false
    
    // Computed property to convert minutes and seconds to TimeInterval
    private var timeInterval: TimeInterval {
        isEnabled ? TimeInterval(minutes * 60 + seconds) : 0
    }
    
    
    var body: some View {
        VStack {
            Form {
                Section {
                    Toggle("Auto Rest Timer", isOn: $isEnabled)
                        .onChange(of: isEnabled) { _, newValue in
                            if !newValue {
                                exerciseDetail.autoRestTimer = 0
                            } else {
                                updateTimeInterval()
                            }
                        }
                }
                
                if isEnabled {
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
            .onChange(of: minutes) { _, _ in
                updateTimeInterval()
            }
            .onChange(of: seconds) { _, _ in
                updateTimeInterval()
            }
        }
        .onAppear {
            let totalSeconds = Int(exerciseDetail.autoRestTimer)
            minutes = totalSeconds / 60
            seconds = totalSeconds % 60
            isEnabled = totalSeconds > 0
        }
    }
    
    private func updateTimeInterval() {
        exerciseDetail.autoRestTimer = timeInterval
    }
}
