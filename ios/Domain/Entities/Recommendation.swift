//
//  Rec.swift
//  QuattSmartAdvisor
//
//  Created by Josevin Johny on 12/11/2025.
//

struct Recommendation {
    let title: String
    let description: String
    let potentialSaving: Double  // € per week
    let priority: Priority
}

enum Priority: Int {
    case high = 3
    case medium = 2
    case low = 1
}
