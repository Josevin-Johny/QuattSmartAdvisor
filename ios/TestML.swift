//
//  TestML.swift
//  QuattSmartAdvisor
//
//  Created by Josevin Johny on 12/11/2025.
//

import Foundation
import CoreML

func testCoreMLModel() {
    print("🧪 Testing CoreML Model...")
    
    do {
        let model = try QuattHeatAdvisorTextClassifierModel(configuration: MLModelConfiguration())
        print("✅ Model loaded successfully!")
        
        let prediction = try model.prediction(text: "How efficient is my heating?")
        print("✅ Prediction: \(prediction.label)")
        
        // Get probabilities from the feature provider
        if let probabilitiesFeature = prediction.featureValue(for: "labelProbabilities"),
           let probabilities = probabilitiesFeature.dictionaryValue as? [String: Double] {
            print("✅ Probabilities: \(probabilities)")
        } else {
            print("⚠️ Probabilities not available")
        }
        
    } catch {
        print("❌ Error: \(error)")
    }
}
