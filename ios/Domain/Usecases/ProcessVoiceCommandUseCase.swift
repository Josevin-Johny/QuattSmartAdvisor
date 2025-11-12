//
//  ProcessVoiceCommandUseCase.swift
//  QuattSmartAdvisor
//
//  Created by Josevin Johny on 12/11/2025.
//

// Domain/UseCases/ProcessVoiceCommandUseCase.swift
import Foundation

protocol ProcessVoiceCommandUseCase {
    func execute(text: String) async -> VoiceCommandResult
}

class ProcessVoiceCommandUseCaseImpl: ProcessVoiceCommandUseCase {
    
    private let intentClassifier: IntentClassifier
    private let analyzeEfficiencyUseCase: AnalyzeHeatingEfficiencyUseCase
    
    init(
        intentClassifier: IntentClassifier,
        analyzeEfficiencyUseCase: AnalyzeHeatingEfficiencyUseCase
    ) {
        self.intentClassifier = intentClassifier
        self.analyzeEfficiencyUseCase = analyzeEfficiencyUseCase
    }
    
    func execute(text: String) async -> VoiceCommandResult {
        // Classify intent using CoreML
        let (command, confidence) = intentClassifier.classifyIntent(from: text)
        
        // Generate response based on intent
        let response = await generateResponse(for: command, confidence: confidence)
        
        return VoiceCommandResult(
            intent: command,
            confidence: confidence,
            response: response,
            processedAt: Date()
        )
    }
    
    private func generateResponse(for command: VoiceCommand, confidence: Double) async -> String {
        // Low confidence
        guard confidence > 0.5 else {
            return "I'm not sure I understood that. Try asking about heating efficiency or costs."
        }
        
        switch command {
        case .analyzeEfficiency:
            return await analyzeEfficiency()
            
        case .predictCosts:
            return predictCosts()
            
        case .recommendSettings:
            return recommendSettings()
            
        case .checkStatus:
            return checkStatus()
            
        case .unknown:
            return "I can help with efficiency analysis, cost predictions, or settings. What would you like to know?"
        }
    }
    
    private func analyzeEfficiency() async -> String {
        do {
            let insight = try await analyzeEfficiencyUseCase.execute(days: 30)
            
            var response = """
            Your system is rated: \(insight.efficiencyRating.rawValue)
            
            Average COP: \(String(format: "%.1f", insight.averageCOP))
            Gas backup usage: \(String(format: "%.0f", insight.gasBackupPercentage))%
            
            """
            
            if let topRecommendation = insight.recommendations.first {
                response += """
                💡 Top Recommendation:
                \(topRecommendation.title)
                
                \(topRecommendation.description)
                
                Potential savings: €\(String(format: "%.0f", topRecommendation.potentialSaving))/week
                """
            }
            
            return response
            
        } catch {
            return "Unable to analyze efficiency right now. Please try again."
        }
    }
    
    private func predictCosts() -> String {
        return """
        Based on weather forecast (dropping to 15°C), next week will cost approximately €8.50.
        
        That's €3 more than this week due to colder temperatures.
        
        Tip: Pre-heat during off-peak hours (11pm-7am) to save money.
        """
    }
    
    private func recommendSettings() -> String {
        return """
        Recommended temperature schedule:
        
        Day (8am-6pm): 20°C
        Evening (6pm-11pm): 21°C
        Night (11pm-8am): 18°C
        
        This optimizes heat pump efficiency while maintaining comfort.
        
        Expected savings: €4/week
        """
    }
    
    private func checkStatus() -> String {
        return """
        
        Your heating system is operating normally.
        
        Current status:
        • COP: 3.2 (Good)
        • Heat pump running efficiently
        • No gas backup needed
        
        System health: Excellent
        """
    }
}
