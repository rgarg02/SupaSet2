import SwiftUI
import Charts
extension VolumeData: DateBasedChartPoint {}
struct VolumeChartSection: View {
    let dataPoints: [VolumeData]
    let dateDomain: ClosedRange<Date>
    let selectedPeriod: StatsPeriod
    @State private var rawSelectedDate: Date?
    
    // New state to toggle average vs total volume
    @State private var showAverage: Bool = false
    
    // Use the centralized animation controller
    @StateObject private var animationController = ChartAnimationController()
    
    // Helper function to compute the displayed volume.
    // If the toggle is enabled for longer time ranges, return the average volume.
    private func computedVolume(for data: VolumeData) -> Double {
        if (selectedPeriod == .threeMonths || selectedPeriod == .year || selectedPeriod == .allTime) && showAverage {
            guard data.workoutCount > 0 else { return 0 }
            return data.totalVolume / Double(data.workoutCount)
        } else {
            return data.totalVolume
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Use the reusable chart component
            if dataPoints.isEmpty {
                ContentUnavailableView("No workout data for this period", systemImage: "chart.line.uptrend.xyaxis", description: Text("Complete workouts to track your progress"))
            } else {
                // Create selection manager
                let selectionManager = ChartSelectionManager(dataPoints: dataPoints)
                
                // Use the reusable WorkoutProgressChart
                WorkoutProgressChart(
                    dataPoints: dataPoints,
                    yValueProvider: { Double(self.computedVolume(for: $0)) },
                    yAxisLabel: "Volume",
                    dateDomain: dateDomain,
                    period: selectedPeriod,
                    rawSelectedDate: $rawSelectedDate,
                    selectedDateProvider: { selectionManager.findClosestDate(to: $0) },
                    lineColor: .primaryTheme,
                    showAverage: $showAverage
                )
                .scaleEffect(animationController.animateScale ? 1 : 0.8)
                .opacity(animationController.animateChart ? 1 : 0)
                .accessibilityLabel("Volume Progress Chart")
            }
        }
        .onChange(of: selectedPeriod) { _, _ in
            animationController.resetAnimation()
            animationController.startAnimation()
        }
        .onAppear {
            animationController.startAnimation()
        }
    }
}
#Preview {
    let preview = PreviewContainer.preview
    WorkoutStatsView()
        .modelContainer(preview.container)
        .environment(preview.viewModel)
        .onAppear {
            Task {
                try await preview.viewModel.loadExercises()
                print("preview : \(preview.viewModel.exercises.count)")
                let workouts = try PreviewContainer.createCompletedWorkouts(using: preview.container.mainContext, exercises: preview.viewModel.exercises)
                for workout in workouts {
                    preview.container.mainContext.insert(workout)
                }
            }
        }
}
