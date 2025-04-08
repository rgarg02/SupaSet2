import SwiftUI
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let delay: Double
    var subtitle: String? = nil
    var trend: Double? = nil
    var trendSuffix: String = ""
    @State private var isVisible: Bool = false
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.accent)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(value)
                .font(.title2)
                .foregroundColor(.theme.text)
                .fontWeight(.bold)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let trend = trend {
                HStack(spacing: 4) {
                    Image(systemName: trend >= 0 ? "arrow.up" : "arrow.down")
                        .font(.caption)
                        .foregroundColor(trend >= 0 ? .green : .red)
                    
                    Text("\(trend >= 0 ? "+" : "")\(String(format: "%.1f", trend))\(trendSuffix)")
                        .font(.caption)
                        .foregroundColor(trend >= 0 ? .green : .red)
                }
            }
            Spacer()
        }
        .padding(8)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            .regularMaterial
        )
        .cornerRadius(12)
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
