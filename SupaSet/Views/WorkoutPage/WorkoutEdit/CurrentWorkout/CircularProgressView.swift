import SwiftUI

struct SetProgressView: View {
    let progress: Double // 0.0 to 1.0
    let isExpanded: Bool
    
    // State to track animated progress
    @State private var animatedProgress: Double = 0
    
    // Clamped progress to ensure valid values
    private var safeProgress: Double {
        max(0, min(1, progress))
    }
    
    // Get color based on progress
    private var progressBaseColor: Color {
        if progress < 0.3 {
            return .themeRed
        } else if progress < 0.7 {
            return .accent
        } else {
            return .primaryThemeColorTwo
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            if isExpanded {
                // Linear progress view
                ZStack(alignment: .leading) {
                    // Background track
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: geometry.size.height)
                    
                    // Foreground progress
                    Rectangle()
                        .fill(progressBaseColor)
                        .frame(width: max(0, min(geometry.size.width, geometry.size.width * animatedProgress)), height: geometry.size.height)
                }
                .cornerRadius(geometry.size.height / 2)
            } else {
                // Circular progress view
                ZStack {
                    // Background circle
                    Circle()
                        .stroke(
                            Color.gray.opacity(0.2),
                            lineWidth: max(1, geometry.size.width * 0.1)
                        )
                    
                    // Progress arc
                    Circle()
                        .trim(from: 0, to: animatedProgress)
                        .stroke(
                            progressBaseColor,
                            style: StrokeStyle(
                                lineWidth: max(1, geometry.size.width * 0.1),
                                lineCap: .round
                            )
                        )
                        .rotationEffect(.degrees(-90))
                }
            }
        }
        .onAppear {
            // Start with zero progress
            animatedProgress = 0
            
            // Animate to actual progress
            withAnimation(.easeInOut(duration: 0.8)) {
                animatedProgress = safeProgress
            }
        }
        .onChange(of: progress) { oldValue, newValue in
            // Animate when progress changes
            withAnimation(.easeInOut(duration: 0.8)) {
                animatedProgress = max(0, min(1, newValue))
            }
        }
        .onChange(of: isExpanded) { oldValue, newValue in
            // Reset and reanimate when expanding/collapsing
            animatedProgress = 0
            
            withAnimation(.easeInOut(duration: 0.8)) {
                animatedProgress = safeProgress
            }
        }
    }
}

// Preview
#Preview {
    @Previewable @State var progress: Double = 0.0
    VStack {
        Slider(value: $progress, in: 0...1)
            .padding()
        VStack {
            // Circular progress preview
            SetProgressView(progress: progress, isExpanded: false)
                .frame(width: 100, height: 100)
            
            // Linear progress preview
            SetProgressView(progress: progress, isExpanded: true)
                .frame(height: 10)
                .padding(.horizontal)
        }
        .frame(height: 250)
        .background(Color.primaryTheme)
        .ignoresSafeArea()
        VStack {
            // Circular progress preview
            SetProgressView(progress: progress, isExpanded: false)
                .frame(width: 100, height: 100)
            
            // Linear progress preview
            SetProgressView(progress: progress, isExpanded: true)
                .frame(height: 10)
                .padding(.horizontal)
        }
        .frame(height: 250)
        .background(Color.primaryTheme)
        .ignoresSafeArea()
        .colorScheme(.dark)
    }
}
