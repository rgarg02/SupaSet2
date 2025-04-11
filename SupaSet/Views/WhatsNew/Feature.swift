//
//  Feature.swift
//  DynamicIslandAnimation
//
//  Created by Rishi Garg on 4/11/25.
//
import SwiftUI

// MARK: - Models

/// Represents a single feature in a What's New page
struct Feature: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let description: String
    let systemName: String?
    init(title: String, description: String, systemName: String? = nil) {
        self.title = title
        self.description = description
        self.systemName = systemName
    }
}

/// Represents a single page within a What's New update
struct WhatsNewPage: Identifiable, Hashable {
    let id = UUID()
    let features: [Feature]
}

/// Represents a complete What's New update with version and pages
struct WhatsNewUpdate: Identifiable {
    let id = UUID()
    let version: String
    let build: String?
    let pages: [WhatsNewPage]
    
    /// Creates a What's New update with specified version and pages
    init(version: String,  build: String? = nil, pages: [WhatsNewPage]) {
        self.build = build
        self.version = version
        self.pages = pages
    }
}

// MARK: - What's New View

/// Main view controller for displaying What's New updates
struct WhatsNewView: View {
    let update: WhatsNewUpdate
    @State private var currentPage = 0
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("What's New")
                    .font(.title)
                    .fontWeight(.bold)
                HStack{
                    Text("Version \(update.version)")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    if let build = update.build {
                        Text("Build \(build)")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.top)
            // Content area - using TabView as page controller
            TabView(selection: $currentPage) {
                ForEach(update.pages.indices, id: \.self) { index in
                    WhatsNewPageView(page: update.pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page)
            .frame(maxHeight: .infinity)
        }
        .background(.regularMaterial)
    }
}

// MARK: - Page View

/// View for a single page in the What's New screen
struct WhatsNewPageView: View {
    let page: WhatsNewPage
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                Spacer()
                ForEach(page.features) { feature in
                    FeatureRow(feature: feature)
                }
                Spacer()
            }
            .frame(maxHeight: .infinity)
            .padding()
        }
    }
}

// MARK: - Feature Row

/// View for a single feature in a What's New page
struct FeatureRow: View {
    let feature: Feature
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            if let systemName = feature.systemName {
                Image(systemName: systemName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .cornerRadius(12)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(feature.title)
                    .font(.headline)
                
                Text(feature.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
    }
}

// MARK: - Preview Provider

/// Helper for creating sample data
struct PreviewData {
    static let sampleUpdate = WhatsNewUpdate(
        version: "2.0",
        build: "15",
        pages: [
            WhatsNewPage(features: [
                Feature(
                    title: "Live Activities",
                    description: "Enjoy the app in dark mode to reduce eye strain and save battery.",
                    systemName: "moon"
                ),
                Feature(
                    title: "Improved Performance",
                    description: "We've optimized the app to load faster and use less memory.",
                    systemName: "bolt"
                )
            ]),
            WhatsNewPage(features: [
                Feature(
                    title: "New Dashboard",
                    description: "Access all your important information at a glance with our redesigned dashboard.",
                    systemName: "chart.bar"
                ),
                Feature(
                    title: "Cloud Sync",
                    description: "Your data is now automatically synced across all your devices.",
                    systemName: "cloud"
                )
            ])
        ]
    )
}

/// Preview for WhatsNewView
struct WhatsNewView_Previews: PreviewProvider {
    static var previews: some View {
        WhatsNewView(update: PreviewData.sampleUpdate)
    }
}
