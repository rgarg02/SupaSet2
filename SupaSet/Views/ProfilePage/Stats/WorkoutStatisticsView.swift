import SwiftUI

struct WorkoutStatsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedPeriod: StatsPeriod = .month
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Period Picker
                    periodPicker
                    
                    WorkoutStatsSection(selectedPeriod: selectedPeriod)
                }
                .padding()
            }
            .navigationTitle("Workout Stats")
            .background(Color(.systemGroupedBackground))
        }
    }
    
    
    
    // MARK: - UI Components
    
    private var periodPicker: some View {
        VStack(alignment: .leading) {
            Text("Time Period")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.leading, 5)
            
            Picker("Time Period", selection: $selectedPeriod) {
                ForEach(StatsPeriod.allCases) { period in
                    Text(period.rawValue).tag(period)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
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
