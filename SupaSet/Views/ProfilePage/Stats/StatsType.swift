//
//  StatsType.swift
//  SupaSet
//
//  Created by Rishi Garg on 3/3/25.
//


import Foundation

enum StatsType: String, CaseIterable, Identifiable {
    case overview = "Overview"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .overview:
            return "chart.bar.fill"
        }
    }
    
    var description: String {
        switch self {
        case .overview:
            return "Key workout metrics and trends"
        }
    }
}
