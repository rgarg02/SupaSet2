//
//  CustomRestTimerView.swift
//  SupaSet
//
//  Created by Rishi Garg on 12/17/24.
//

import SwiftUI
struct CustomRestTimerView: View {
    @Binding var selectedTime: TimeInterval
    @Binding var showRestTimer: Bool
    @State private var isAutoRestEnabled = false
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    withAnimation(.easeInOut) {
                        showRestTimer = false
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.theme.accent)
                }
                .padding(.leading)
                Text("Rest Timer")
                    .font(.headline)
                Spacer()
            }
            .padding(.vertical)
            
            // Rest of the form content
            Form {
                Section {
                    Toggle("Auto Rest Timer", isOn: $isAutoRestEnabled)
                }
                if isAutoRestEnabled{
                    Section("Rest Duration") {
                        HStack(spacing: 0) {
                            Picker("Minutes", selection: .init(
                                get: { Int(selectedTime) / 60 },
                                set: { selectedTime = TimeInterval($0 * 60 + Int(selectedTime.truncatingRemainder(dividingBy: 60))) }
                            )) {
                                ForEach(0..<11) { minute in
                                    Text("\(minute)")
                                        .tag(minute)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: 100)
                            
                            Text("min")
                                .font(.body)
                            
                            Picker("Seconds", selection: .init(
                                get: { Int(selectedTime.truncatingRemainder(dividingBy: 60)) },
                                set: { selectedTime = TimeInterval(Int(selectedTime / 60) * 60 + $0) }
                            )) {
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
                        .sensoryFeedback(.impact, trigger: selectedTime)
                    }
                }
            }
            .foregroundColor(.theme.text)
        }
        .padding(.top)
        .transition(.move(edge: .trailing))
        .frame(width: 320, height: 400)
        .background(Color.theme.primary)
    }
}
#Preview("Custom Rest Timer") {
    CustomRestTimerView(selectedTime: .constant(60), showRestTimer: .constant(true))
}