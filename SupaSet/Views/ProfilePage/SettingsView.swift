//
//  SettingsView.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/27/25.
//


import SwiftUI
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.isChildPresenting) private var isChildPresenting
    var body: some View {
        NavigationStack {
            List {
                Section("Account") {
                    NavigationLink("Import Strong Data") {
                        CSVImportView()
                            .onAppear{
                                isChildPresenting.wrappedValue = true
                            }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
