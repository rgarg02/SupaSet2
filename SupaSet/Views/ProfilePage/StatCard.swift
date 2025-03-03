import SwiftUI
// Supporting Views
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let delay: Double
    @State private var isVisible: Bool = false
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.theme.accent)
            
            Text(value)
                .font(.title2)
                .foregroundColor(.theme.text)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.theme.text)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.theme.background)
                .shadow(color: Color.theme.text, radius: 1)
        )
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 20)
        .scaleEffect(isVisible ? 1 : 0.9)
        .animation(
            .spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.2)
            .delay(delay),
            value: isVisible
        )
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isVisible = true
            }
        }
        .onDisappear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isVisible = false
            }
        }
    }
}

#Preview {
    HStack(spacing: 20) {
        StatCard(title: "Workouts", value: "0", icon: "dumbbell.fill", delay: 0.0)
        StatCard(title: "Hours", value: "0", icon: "clock.fill", delay: 0.2)
        StatCard(title: "Streak", value: "0", icon: "flame.fill", delay: 0.3)
    }
}
