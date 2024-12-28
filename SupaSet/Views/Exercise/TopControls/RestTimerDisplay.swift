//
//  RestTimerDisplay.swift
//  SupaSet
//
//  Created by Rishi Garg on 12/23/24.
//

import SwiftUI
import SwiftData

struct RestTimerDisplay: View {
    let exerciseDetail: ExerciseDetail
    var body: some View {
        if exerciseDetail.autoRestTimer > 0 {
            Text(exerciseDetail.autoRestTimer.formatAsTimerString())
                .foregroundColor(.theme.accent)
            
        }
    }
}
