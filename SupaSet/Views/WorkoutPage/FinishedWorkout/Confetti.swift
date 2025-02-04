//
//  Confetti.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/30/25.
//
import SwiftUI
struct ConfettiView: View {
    @State private var animate = false
    private let colors: [Color] = [.red, .blue, .green, .yellow, .pink, .purple, .orange]
    
    var body: some View {
        ZStack {
            ForEach(0..<200, id: \.self) { _ in
                ConfettiParticle()
                    .foregroundColor(colors.randomElement()!)
            }
        }
        .opacity(animate ? 0 : 1)
        .onAppear {
            withAnimation(.easeOut(duration: 2.0)) {
                animate = true
            }
        }
    }
}

struct ConfettiParticle: View {
    @State private var direction: CGFloat = CGFloat.random(in: -1...1)
    @State private var rotation: CGFloat = CGFloat.random(in: 0...360)
    @State private var position: CGPoint = CGPoint(
        x: CGFloat.random(in: 0.2...0.8),
        y: CGFloat.random(in: 0...1)
    )
    
    var body: some View {
        Circle()
            .frame(width: 6, height: 6)
            .scaleEffect(1.5)
            .modifier(ConfettiModifier(
                direction: direction,
                rotation: rotation,
                position: position
            ))
            .opacity(position.y > 0.8 ? CGFloat(1 - position.y) : 1)
    }
}

struct ConfettiModifier: ViewModifier {
    let direction: CGFloat
    let rotation: CGFloat
    let position: CGPoint
    
    @State private var time: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(rotation + time * 360))
            .offset(x: time * 400 * direction, y: time * 600)
            .position(
                x: UIScreen.main.bounds.width * position.x,
                y: UIScreen.main.bounds.height * position.y
            )
            .onAppear {
                withAnimation(.linear(duration: 2.0)) {
                    self.time = 1
                }
            }
    }
}
