import SwiftUI

struct WorkoutStatsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedPeriod: StatsPeriod = .month
    @State private var selectedStatsType: StatsType = .overview
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Stats Type Selector
                statsTypePicker
                
                // Period Picker
                PeriodPicker(selectedPeriod: $selectedPeriod)
                
                // Dynamic content based on selected stats type
                switch selectedStatsType {
                case .overview:
                    WorkoutStatsSection(selectedPeriod: selectedPeriod)
                }
            }
            .padding()
        }
        .navigationTitle("Workout Stats")
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - UI Components
    
    private var statsTypePicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(StatsType.allCases) { type in
                    statsTypeButton(for: type)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func statsTypeButton(for type: StatsType) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedStatsType = type
            }
        }) {
            VStack(spacing: 8) {
                Image(systemName: type.icon)
                    .font(.title2)
                    .foregroundColor(selectedStatsType == type ? .white : .primary)
                Text(type.rawValue)
                    .font(.subheadline)
                    .foregroundColor(selectedStatsType == type ? .white : .primary)
            }
            .frame(width: 100, height: 80)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(selectedStatsType == type ? Color.blue : Color(.secondarySystemBackground))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// SwiftUI Preview
struct WorkoutStatsView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutStatsView()
            .modelContainer(for: [
                SupaSetSchemaV1.Workout.self,
                SupaSetSchemaV1.WorkoutExercise.self,
                SupaSetSchemaV1.ExerciseSet.self
            ])
    }
}
