//
//  StatsType.swift
//  SupaSet
//
//  Created by Rishi Garg on 3/3/25.
//


import Foundation

enum StatsType: String, CaseIterable, Identifiable {
    case overview = "Overview"
    case performance = "Performance"
    case predictions = "Predictions"
    case researchInsights = "Research"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .overview:
            return "chart.bar.fill"
        case .performance:
            return "chart.line.uptrend.xyaxis"
        case .predictions:
            return "chart.xyaxis.line"
        case .researchInsights:
            return "doc.text.magnifyingglass"
        }
    }
    
    var description: String {
        switch self {
        case .overview:
            return "Key workout metrics and trends"
        case .performance:
            return "Detailed analysis of your progress"
        case .predictions:
            return "AI-powered forecasts based on your data"
        case .researchInsights:
            return "Evidence-based workout insights"
        }
    }
}