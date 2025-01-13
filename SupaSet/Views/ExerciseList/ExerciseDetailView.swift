//
//  ExerciseDetailView.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/11/25.
//

import SwiftUI

struct ExerciseDetailView: View {
    let exercise: Exercise
    @State private var selectedImageIndex = 0
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header with name and category
                VStack(alignment: .leading, spacing: 8) {
                    Text(exercise.name)
                        .font(.largeTitle)
                        .bold()
                    
                    HStack {
                        if let equipment = exercise.equipment {
                            equipment.image
                                .font(.title2)
                        }
                        Text(exercise.category.rawValue.capitalized)
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                // Images carousel
                if !exercise.images.isEmpty {
                    TabView(selection: $selectedImageIndex) {
                        ForEach(Array(exercise.images.enumerated()), id: \.element) { index, imageUrl in
                            ExerciseImageView(imagePath: imageUrl)
                                .tag(index)
                        }
                    }
                    .frame(height: 250)
                    .tabViewStyle(PageTabViewStyle())
                }
                
                // Exercise details
                VStack(alignment: .leading, spacing: 16) {
                    // Level indicator
                    HStack {
                        Text("Level:")
                            .font(.headline)
                        Text(exercise.level.rawValue.capitalized)
                            .foregroundColor(exercise.level.color)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(exercise.level.color.opacity(0.2))
                            )
                    }
                    
                    // Mechanics and Force
                    if let mechanic = exercise.mechanic {
                        DetailRow(title: "Mechanic", value: mechanic.rawValue.capitalized)
                    }
                    
                    if let force = exercise.force {
                        DetailRow(title: "Force", value: force.rawValue.capitalized)
                    }
                    
                    // Muscles involved
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Primary Muscles")
                            .font(.headline)
                        MuscleTagsView(muscles: exercise.primaryMuscles)
                        
                        if !exercise.secondaryMuscles.isEmpty {
                            Text("Secondary Muscles")
                                .font(.headline)
                                .padding(.top, 8)
                            MuscleTagsView(muscles: exercise.secondaryMuscles)
                        }
                    }
                    
                    // Instructions
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Instructions")
                            .font(.headline)
                        
                        ForEach(Array(exercise.instructions.enumerated()), id: \.offset) { index, instruction in
                            HStack(alignment: .top, spacing: 8) {
                                Text("\(index + 1).")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text(instruction)
                                    .font(.subheadline)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .padding()
            }
        }
    }
    
}
struct ExerciseImageView: View {
    let imagePath: String

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
            print("Bundle not found")
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

#Preview {
    ExerciseDetailView(exercise: Exercise(
        id: "1",
        name: "Bench Press",
        force: .push,
        level: .intermediate,
        mechanic: .compound,
        equipment: .bands,
        primaryMuscles: [.chest, .triceps, .shoulders],
        secondaryMuscles: [.forearms],
        instructions: ["Sample instruction"],
        category: .strength,
        images: []
    ))
        
}
