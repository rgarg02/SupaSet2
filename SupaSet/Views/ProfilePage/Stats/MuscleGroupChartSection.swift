//
//  MuscleGroupChartSection.swift
//  SupaSet
//
//  Created by Rishi Garg on 3/3/25.
//

import SwiftUI
import Charts
// MARK: - Muscle Group Chart Subview

struct MuscleGroupChartSection: View {
    let dataPoints: [MuscleGroupData]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Muscle Focus")
                .font(.title2)
                .fontWeight(.bold)
            if dataPoints.isEmpty {
                Text("No muscle data for this period")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 200)
            } else {
                Chart {
                    ForEach(dataPoints) { data in
                        BarMark(
                            x: .value("Volume", data.totalVolume),
                            y: .value("Muscle", data.muscleGroup)
                        )
                        .foregroundStyle(Color.purple.gradient)
                        .cornerRadius(6)
                    }
                }
                .frame(height: 250)
                .chartXAxis { AxisMarks() }
                .chartYAxis { AxisMarks() }
                .accessibilityLabel("Muscle Group Distribution Chart")
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
}
