import SwiftUI
import Charts

// MARK: - Muscle Group Chart Subview

struct MuscleGroupChartSection: View {
    let dataPoints: [MuscleGroupData]
    @State private var rawSelectedMuscleGroup: Double?
    
    // Computed property to get the selected muscle group name
    private var selectedMuscleGroup: String? {
        guard let rawValue = rawSelectedMuscleGroup else { return nil }
        
        // Track running total to determine which sector was selected
        var runningTotal: Double = 0
        
        for data in dataPoints {
            runningTotal += data.totalVolume
            if rawValue <= runningTotal {
                return data.muscleGroup
            }
        }
        
        return nil
    }
    
    // Computed property to get the complete data for the selected muscle group
    private var selectedMuscleData: MuscleGroupData? {
        guard let selectedMuscleGroup else { return nil }
        return dataPoints.first { $0.muscleGroup == selectedMuscleGroup }
    }
    
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
                        SectorMark(
                            angle: .value("Volume", data.totalVolume),
                            innerRadius: .ratio(0.618),
                            angularInset: 1.5
                        )
                        .cornerRadius(5)
                        .foregroundStyle(by: .value("Muscle", data.muscleGroup))
                    }
                }
                .chartAngleSelection(value: $rawSelectedMuscleGroup)
                .onChange(of: rawSelectedMuscleGroup) { oldValue, newValue in
                    // Log the selected muscle group when selection changes
                    if let selected = selectedMuscleGroup {
                        print("Selected muscle group: \(selected)")
                    } else {
                        print("No muscle group selected")
                    }
                }
                .chartBackground(content: { chartProxy in
                    GeometryReader { geometry in
                        let frame = geometry[chartProxy.plotFrame!]
                        VStack{
                            if let selected = selectedMuscleGroup, let data = selectedMuscleData {
                                Text(selected)
                                    .font(.footnote)
                                Text("Volume: \(Int(data.totalVolume))")
                                    .font(.caption.bold())
                            } else {
                                Text("Most Hit Muscles")
                                    .font(.footnote)
                                Text("Total Volume: \(Int(dataPoints.map(\.totalVolume).reduce(0, +)))")
                                    .font(.caption.bold())
                            }
                        }
                        .position(x: frame.midX, y: frame.midY)
                    }
                })
                .frame(height: 300)
                .chartLegend(position: .bottom, alignment: .leading)
                .accessibilityLabel("Muscle Group Distribution Chart")
                        
            }
        }
        .sensoryFeedback(.impact, trigger: selectedMuscleGroup)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
}
