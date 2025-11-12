//
//  DependencyContainer.swift
//  QuattSmartAdvisor
//
//  Created by Josevin Johny on 12/11/2025.
//

// Core/DI/DependencyContainer.swift
import Foundation

class DependencyContainer {
    
    // MARK: - Singleton
    static let shared = DependencyContainer()
    
    private init() {}
    
    // MARK: - Data Layer
    lazy var heatingRepository: HeatingRepository = {
        HeatingRepositoryImpl(simulateDelay: true)
    }()
    
    // MARK: - Core Layer
    lazy var intentClassifier: IntentClassifier = {
        IntentClassifier()
    }()
    
    lazy var speechService: SpeechRecognitionServiceProtocol = {
        SpeechRecognitionService()
    }()
  
    
    // MARK: - Domain Layer (Use Cases)
    lazy var analyzeEfficiencyUseCase: AnalyzeHeatingEfficiencyUseCase = {
        AnalyzeHeatingEfficiencyUseCaseImpl(repository: heatingRepository)
    }()
    
    lazy var processVoiceCommandUseCase: ProcessVoiceCommandUseCase = {
        ProcessVoiceCommandUseCaseImpl(
            intentClassifier: intentClassifier,
            analyzeEfficiencyUseCase: analyzeEfficiencyUseCase
        )
    }()
}

