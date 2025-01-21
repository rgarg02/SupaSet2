//
//  R.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/14/25.
//

import SwiftUI

struct RadarChartView: View {
    let muscleGroups: [String]
    let volumes: [Double]
    
    var body: some View {
        GeometryReader { geometry in
            let radius = min(geometry.size.width, geometry.size.height) / 2
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            
            ZStack {
                // Draw the grid
                ForEach(1...5, id: \.self) { level in
                    PolygonShape(sides: muscleGroups.count, scale: CGFloat(level) / 5)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        .frame(width: radius * 2, height: radius * 2)
                        .position(center)
                }
                
                // Draw the radar data
                PolygonShape(sides: muscleGroups.count, data: volumes, maxValue: volumes.max() ?? 1)
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: radius * 2, height: radius * 2)
                    .position(center)
                
                // Add labels
                ForEach(0..<muscleGroups.count, id: \.self) { index in
                    Text(muscleGroups[index])
                        .font(.caption)
                        .position(
                            x: center.x + radius * cos(angle(for: index)),
                            y: center.y + radius * sin(angle(for: index))
                        )
                }
            }
        }
    }
    
    func angle(for index: Int) -> CGFloat {
        CGFloat(index) / CGFloat(muscleGroups.count) * 2 * .pi - .pi / 2
    }
}

struct PolygonShape: Shape {
    var sides: Int
    var scale: CGFloat = 1
    var data: [Double] = []
    var maxValue: Double = 1
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2 * scale
        
        var path = Path()
        for i in 0..<sides {
            let angle = CGFloat(i) / CGFloat(sides) * 2 * .pi - .pi / 2
            let value = data.isEmpty ? 1 : CGFloat(data[i] / maxValue)
            let point = CGPoint(
                x: center.x + radius * value * cos(angle),
                y: center.y + radius * value * sin(angle)
            )
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}

#Preview {
    RadarChartView(
                muscleGroups: ["Chest", "Back", "Legs", "Arms", "Shoulders","Legs", "Arms", "Shoulders"],
                volumes: [1200, 900, 1400, 800, 700,1000, 800, 700] // Replace with computed volumes
            )
            .padding()
}
