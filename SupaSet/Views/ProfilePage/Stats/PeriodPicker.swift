//
//  PeriodPicker.swift
//  SupaSet
//
//  Created by Rishi Garg on 3/4/25.
//

import SwiftUI

struct PeriodPicker: View {
    @Binding var selectedPeriod: StatsPeriod
    var body: some View {
        VStack(alignment: .leading) {
            Text("Time Period")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.leading, 5)
            
            Picker("Time Period", selection: $selectedPeriod) {
                ForEach(StatsPeriod.allCases) { period in
                    Text(period.rawValue).tag(period)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
}
