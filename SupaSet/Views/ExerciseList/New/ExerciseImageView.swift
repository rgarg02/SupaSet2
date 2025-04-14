//
//  ExerciseImageView.swift
//  SupaSetGRDB
//
//  Created by Rishi Garg on 4/13/25.
//

import SwiftUI


struct ExerciseImageView: View {
    let imagePath: String
    @Environment(\.alertController) private var alertController
    var body: some View {
        if let image = loadImage(from: imagePath) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
        } else {
            Text("Image not found")
                .foregroundColor(.red)
        }
    }
    
    func loadImage(from path: String) -> UIImage? {
        // Get the bundle
        guard let bundlePath = Bundle.main.path(forResource: "exerciseImages", ofType: "bundle"),
              let bundle = Bundle(path: bundlePath) else {
            return nil
        }
        // Load the image
        return UIImage(named: path, in: bundle, compatibleWith: nil)
    }
}
// Helper Views
struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title + ":")
                .font(.headline)
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

struct MuscleTagsView: View {
    let muscles: [MuscleGroup]
    
    var body: some View {
        FlowLayout(alignment: .leading, spacing: 8) {
            ForEach(muscles, id: \.self) { muscle in
                Text(muscle.rawValue.capitalized)
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.blue.opacity(0.1))
                    )
                    .foregroundColor(.blue)
            }
        }
    }
}

// Helper view for wrapping tags
struct FlowLayout: Layout {
    var alignment: HorizontalAlignment = .center
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            alignment: alignment,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            alignment: alignment,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                    y: bounds.minY + result.positions[index].y),
                         proposal: ProposedViewSize(result.sizes[index]))
        }
    }
    
    struct FlowResult {
        var positions: [CGPoint]
        var sizes: [CGSize]
        var size: CGSize
        
        init(in maxWidth: CGFloat, subviews: Subviews, alignment: HorizontalAlignment, spacing: CGFloat) {
            var currentPosition = CGPoint.zero
            var maxY: CGFloat = 0
            var positions: [CGPoint] = []
            var sizes: [CGSize] = []
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                if currentPosition.x + size.width > maxWidth, currentPosition.x > 0 {
                    currentPosition.x = 0
                    currentPosition.y = maxY + spacing
                }
                positions.append(currentPosition)
                sizes.append(size)
                
                currentPosition.x += size.width + spacing
                maxY = max(maxY, currentPosition.y + size.height)
            }
            
            self.positions = positions
            self.sizes = sizes
            self.size = CGSize(width: maxWidth, height: maxY)
        }
    }
}
