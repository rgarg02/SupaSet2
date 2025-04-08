import SwiftUI
import Charts

struct TopExerciseSection: View {
    let topExercisesList: [(exerciseID: String, name: String, weight: Double)]
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Top Exercises")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
            }
            
            if topExercisesList.isEmpty {
                VStack {
                    Image(systemName: "dumbbell.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary.opacity(0.5))
                        .padding()
                    
                    Text("No exercise data for this period")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, minHeight: 150)
            } else {
                VStack(spacing: 12) {
                    ForEach(topExercisesList.indices, id: \.self) { index in
                        NavigationLink {
                            ExerciseStatView(exerciseID: topExercisesList[index].exerciseID)
                        } label: {
                            HStack {
                                // Ranking circle
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: getRankColors(index),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 32, height: 32)
                                    
                                    Text("\(index + 1)")
                                        .font(.callout.bold())
                                        .foregroundColor(.white)
                                }
                                
                                // Exercise details
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(topExercisesList[index].name)
                                        .font(.subheadline.weight(.semibold))
                                        .lineLimit(1)
                                }
                                
                                Spacer()
                                
                                // Weight indicator
                                Text("\(Int(topExercisesList[index].weight)) kg")
                                    .font(.callout.weight(.medium))
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                                
                                // Navigation chevron
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 6)
                            .contentShape(Rectangle())
                        }
                        
                        if index < topExercisesList.count - 1 {
                            Divider()
                                .padding(.leading, 40)
                        }
                    }
                }
            }
        }
    }
    
    // Get colors based on ranking
    private func getRankColors(_ index: Int) -> [Color] {
        switch index {
        case 0: return [.blue, .purple] // 1st place
        case 1: return [.blue.opacity(0.9), .blue] // 2nd place
        case 2: return [.blue.opacity(0.8), .blue.opacity(0.9)] // 3rd place
        default: return [.blue.opacity(0.6), .blue.opacity(0.7)] // Others
        }
    }
    
    // Calculate progress width relative to maximum weight
    private func getProgressWidth(_ totalWidth: CGFloat, _ index: Int) -> CGFloat {
        guard !topExercisesList.isEmpty else { return 0 }
        
        let maxWeight = topExercisesList.map { $0.weight }.max() ?? 1
        let currentWeight = topExercisesList[index].weight
        
        return (currentWeight / maxWeight) * totalWidth
    }
}

#Preview {
    TopExerciseSection(topExercisesList: [
        (exerciseID: "ex1", name: "Bench Press", weight: 120.0),
        (exerciseID: "ex2", name: "Squat", weight: 150.0),
        (exerciseID: "ex3", name: "Deadlift", weight: 180.0),
        (exerciseID: "ex4", name: "Pull-up", weight: 80.0),
        (exerciseID: "ex5", name: "Shoulder Press", weight: 60.0)
    ])
    .padding()
    .background(Color(.systemGroupedBackground))
}
