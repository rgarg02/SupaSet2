//
//  ExercisePickerOverlay.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/21/24.
//
import SwiftUI

struct ExercisePickerOverlay: View {
    @Binding var isPresented: Bool
    var workout: Workout
    var width: CGFloat
    var height: CGFloat
    
    var body: some View {
        ZStack {
            Color.background.opacity(0.75)
                .onTapGesture {
                    withAnimation {
                        isPresented = false
                    }
                }
            
            ExerciseListPickerView(
                isPresented: $isPresented,
                workout: workout
            )
            .shadow(radius: 10)
            .ignoresSafeArea()
            .frame(width: width * 0.9, height: height * 0.6)
            .transition(.move(edge: .trailing))
        }
    }
}
