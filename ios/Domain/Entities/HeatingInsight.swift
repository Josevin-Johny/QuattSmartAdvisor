//
//  HeatingInsight.swift
//  QuattSmartAdvisor
//
//  Created by Josevin Johny on 12/11/2025.
//

// Domain/Entities/HeatingInsight.swift
import Foundation

struct HeatingInsight {
    let averageCOP: Double
    let efficiencyRating: EfficiencyRating
    let gasBackupPercentage: Double
    let recommendations: [Recommendation]
    let potentialSavings: Double  // € per week
    let period: DateInterval
}

enum EfficiencyRating: String {
    case excellent = "Excellent"
    case good = "Good"
    case average = "Average"
    case poor = "Poor"
    case veryPoor = "Very Poor"
    
    var color: String {
        switch self {
        case .excellent: return "green"
        case .good: return "lightgreen"
        case .average: return "yellow"
        case .poor: return "orange"
        case .veryPoor: return "red"
        }
    }
    
}

