//
//  ChangeUnitView.swift
//  SupaSet
//
//  Created by Rishi Garg on 12/24/24.
//
import SwiftUI
import SwiftData

struct ChangeUnitView: View {
    @Bindable var exerciseDetail: ExerciseDetail
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Change Unit")
                .font(.title)
                .fontWeight(.bold)
            Picker("Unit", selection: $exerciseDetail.unit) {
                ForEach(Unit.allCases, id: \.self) { unit in
                    Text(unit.rawValue)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
        }
        .padding()
    }
}
