//
//  ScrollContent+Funcs.swift
//  SupaSet
//
//  Created by Rishi Garg on 12/10/24.
//

import SwiftUI
extension ScrollContentView {
    func checkAndScroll(_ location: CGPoint) {
        let centeredLocation = CGPoint(
            x: parentFrame.midX,
            y: location.y
        )
        
        let topStatus = topRegion.contains(centeredLocation)
        let bottomStatus = bottomRegion.contains(centeredLocation)
        
        if !topStatus && !bottomStatus {
            scrollTimer?.invalidate()
            scrollTimer = nil
            return
        }
        
        guard scrollTimer == nil else { return }
        
        scrollTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            guard let currentIndex = sortedExercises.firstIndex(where: { $0.id == selectedExercise?.id }) else { return }
            
            var nextIndex = currentIndex
            
            if topStatus {
                nextIndex = max(currentIndex - 1, 0)
            } else {
                nextIndex = min(currentIndex + 1, sortedExercises.count - 1)
            }
            
            guard nextIndex != currentIndex else {
                scrollTimer?.invalidate()
                scrollTimer = nil
                return
            }
            
            lastActiveScrollId = sortedExercises[nextIndex].id
            withAnimation(.smooth(duration: 0.1)) {
                scrolledExercise = lastActiveScrollId
            }
        }
    }
    
    func checkAndSwapItems(_ location: CGPoint) {
        guard let currentExercise = exercises.first(where: { $0.id == selectedExercise?.id }) else { return }
        
        let centeredLocation = CGPoint(
            x: parentFrame.midX,
            y: location.y
        )
        
        let fallingExercise = exercises.first { exercise in
            guard exercise.id != currentExercise.id else { return false }
            let frame = exerciseFrames[exercise.id] ?? .zero
            return centeredLocation.y >= frame.minY && centeredLocation.y <= frame.maxY
        }
        
        guard let fallingExercise = fallingExercise else { return }
        
        let currentIndex = currentExercise.order
        let fallingIndex = fallingExercise.order
        
        guard currentIndex != fallingIndex else { return }
        hapticsTrigger.toggle()
        withAnimation(.snappy(duration: 0.25, extraBounce: 0)) {
            currentExercise.order = fallingIndex
            fallingExercise.order = currentIndex
        }
    }
}
