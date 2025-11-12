
//  IntentClassifier.swift
//  QuattSmartAdvisor
//
//  Created by Josevin Johny on 12/11/2025.


import Foundation
import CoreML


enum VoiceCommand {
    case analyzeEfficiency
    case predictCosts
    case recommendSettings
    case checkStatus
    case unknown
}

class IntentClassifier {
    private var model: QuattHeatAdvisorTextClassifierModel?
    
    init() {
        do {
            let config = MLModelConfiguration()
            config.computeUnits = .all
            self.model = try QuattHeatAdvisorTextClassifierModel(configuration: config)
            print("✅ CoreML model loaded successfully")
        } catch {
            print("❌ Failed to load CoreML model: \(error)")
        }
    }
    
    func classifyIntent(from text: String) -> (command: VoiceCommand, confidence: Double) {
        guard let model = model else {
            print("❌ Model not loaded")
            return (.unknown, 0.0)
        }
        
        do {
            let prediction = try model.prediction(text: text)
            let label = prediction.label
            
            var confidence: Double = 0.0
            if let probabilitiesFeature = prediction.featureValue(for: "labelProbabilities"),
               let probabilities = probabilitiesFeature.dictionaryValue as? [String: Double] {
                confidence = probabilities[label] ?? 0.0
                print("✅ CoreML - Label: \(label), Confidence: \(String(format: "%.2f", confidence))")
            } else {
                confidence = 1.0
                print("✅ CoreML - Label: \(label) (confidence not available)")
            }
            
            let command = mapToCommand(label)
            return (command, confidence)
            
        } catch {
            print("❌ Prediction error: \(error)")
            return (.unknown, 0.0)
        }
    }
    
    private func mapToCommand(_ label: String) -> VoiceCommand {
        switch label {
        case "efficiency":
            return .analyzeEfficiency
        case "cost":
            return .predictCosts
        case "settings":
            return .recommendSettings
        case "status":
            return .checkStatus
        default:
            return .unknown
        }
    }
}
