//
//  SettingsView.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/27/25.
//


import SwiftUI
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section("Account") {
                    NavigationLink("Personal Information") {
                        Text("Personal Information")
                    }
                    NavigationLink("Privacy") {
                        Text("Privacy Settings")
                    }
                    NavigationLink("Notifications") {
                        Text("Notification Settings")
                    }
                    NavigationLink("Import Strong Data") {
                        CSVImportView()
                    }
                }
                
                Section("App") {
                    NavigationLink("Appearance") {
                        Text("Appearance Settings")
                    }
                    NavigationLink("Units") {
                        Text("Unit Settings")
                    }
                }
                
                Section("About") {
                    NavigationLink("Terms of Service") {
                        Text("Terms of Service")
                    }
                    NavigationLink("Privacy Policy") {
                        Text("Privacy Policy")
                    }
                    NavigationLink("App Version") {
                        Text("Version 1.0.0")
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
