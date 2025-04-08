import SwiftUI

/// A UIViewRepresentable that creates a truly transparent blur effect
struct TransparentBlurView: UIViewRepresentable {
    var removeAllFilters: Bool = false
    
    func makeUIView(context: Context) -> TransparentBlurViewHelper {
        return TransparentBlurViewHelper(removeAllFilters: removeAllFilters)
    }
    
    func updateUIView(_ uiView: TransparentBlurViewHelper, context: Context) {
        // No updates needed
    }
}

/// Helper class for creating a transparent blur effect
class TransparentBlurViewHelper: UIVisualEffectView {
    init(removeAllFilters: Bool) {
        super.init(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        
        // Removing Background View to maintain transparency
        if subviews.indices.contains(1) {
            subviews[1].alpha = 0
        }
        
        if let backdropLayer = layer.sublayers?.first {
            if removeAllFilters {
                backdropLayer.filters = []
            } else {
                // Removing all filters except the Gaussian blur
                backdropLayer.filters?.removeAll(where: { filter in
                    String(describing: filter) != "gaussianBlur"
                })
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Disabling trait changes to maintain consistent appearance
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        // Intentionally empty to prevent changes when traits change
    }
}

extension View {
    /// Applies a glassmorphism effect to any view
    /// - Parameters:
    ///   - cornerRadius: The corner radius of the glass effect
    ///   - blurIntensity: Whether to use a more intense blur (removes all filters except gaussian)
    ///   - borderWidth: Width of the border
    ///   - borderColor: Color of the border
    ///   - shadowRadius: The radius of the shadow
    ///   - shadowColor: Color of the shadow
    ///   - shadowOffset: Offset of the shadow
    func glassmorphism(
        cornerRadius: CGFloat = 12,
        blurIntensity: Bool = false,
        borderWidth: CGFloat = 0.5,
        borderColor: Color = Color.white.opacity(0.2),
        shadowRadius: CGFloat = 5,
        shadowColor: Color = Color.black.opacity(0.2),
        shadowOffset: CGFloat = 2
    ) -> some View {
        self
            .background {
                // Use the transparent blur view with proper blur settings
                TransparentBlurView(removeAllFilters: blurIntensity)
                
                // Add a subtle gradient overlay for light reflection
                LinearGradient(
                    gradient: Gradient(
                        colors: [
                            Color.white.opacity(0.25),
                            Color.clear,
                            Color.white.opacity(0.1)
                        ]
                    ),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .blendMode(.overlay)
            }
            // Apply border
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            // Apply corner radius
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            // Apply shadow for depth
            .shadow(
                color: shadowColor,
                radius: shadowRadius,
                x: 0,
                y: shadowOffset
            )
    }
    
    /// A preset for card-style glassmorphism
    func cardGlass() -> some View {
        self.glassmorphism(
            cornerRadius: 12,
            blurIntensity: false,
            borderWidth: 0.5,
            borderColor: Color.white.opacity(0.25),
            shadowRadius: 4,
            shadowColor: Color.black.opacity(0.15),
            shadowOffset: 2
        )
    }
    
    /// A preset for dialog-style glassmorphism with more intense blur
    func dialogGlass() -> some View {
        self.glassmorphism(
            cornerRadius: 16,
            blurIntensity: true,
            borderWidth: 0.8,
            borderColor: Color.white.opacity(0.3),
            shadowRadius: 8,
            shadowColor: Color.black.opacity(0.2),
            shadowOffset: 3
        )
    }
    
    /// A preset for toolbar-style glassmorphism with subtle effect
    func toolbarGlass() -> some View {
        self.glassmorphism(
            cornerRadius: 8,
            blurIntensity: false,
            borderWidth: 0.4,
            borderColor: Color.white.opacity(0.15),
            shadowRadius: 2,
            shadowColor: Color.black.opacity(0.1),
            shadowOffset: 1
        )
    }
}
