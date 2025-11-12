//
//  VoiceCommandResult.swift
//  QuattSmartAdvisor
//
//  Created by Josevin Johny on 12/11/2025.
//

// Domain/Entities/VoiceCommandResult.swift
import Foundation

struct VoiceCommandResult {
    let intent: VoiceCommand
    let confidence: Double
    let response: String
    let processedAt: Date
}


