//
//  TemplateInfoView.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/22/25.
//

import SwiftUI

struct TemplateExerciseInfoView: View {
    @Bindable var templateExericse: TemplateExercise
    @Environment(ExerciseViewModel.self) var viewModel
    var body: some View {
        HStack {
            Text(viewModel.getExerciseName(for: templateExericse.exerciseID))
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.theme.text)
        }
    }
}
