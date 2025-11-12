//
//  SmartAdvisorViewModel.swift
//  QuattSmartAdvisor
//
//  Created by Josevin Johny on 12/11/2025.
//

// Presentation/ViewModels/SmartAdvisorViewModel.swift

import Foundation
import Combine

@MainActor
class SmartAdvisorViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var isLoading = false
    @Published var isListening = false
    @Published var recognizedText = ""
    @Published var aiResponse: String?
    @Published var currentInsight: HeatingInsight?
    @Published var errorMessage: String?
    
    // NEW: Chart data
    @Published var historicalData: [HeatingData] = []
    @Published var selectedChartMetric: ChartMetric = .cop
    
    // MARK: - Dependencies
    private let processVoiceCommandUseCase: ProcessVoiceCommandUseCase
    private let analyzeEfficiencyUseCase: AnalyzeHeatingEfficiencyUseCase
    private let heatingRepository: HeatingRepository
    private let speechService: SpeechRecognitionServiceProtocol
    
    // MARK: - Init
    init(
        processVoiceCommandUseCase: ProcessVoiceCommandUseCase,
        analyzeEfficiencyUseCase: AnalyzeHeatingEfficiencyUseCase,
        heatingRepository: HeatingRepository,
        speechService: SpeechRecognitionServiceProtocol
    ) {
        self.processVoiceCommandUseCase = processVoiceCommandUseCase
        self.analyzeEfficiencyUseCase = analyzeEfficiencyUseCase
        self.heatingRepository = heatingRepository
        self.speechService = speechService
    }
    
    // MARK: - Convenience Init
    convenience init() {
        let container = DependencyContainer.shared
        self.init(
            processVoiceCommandUseCase: container.processVoiceCommandUseCase,
            analyzeEfficiencyUseCase: container.analyzeEfficiencyUseCase,
            heatingRepository: container.heatingRepository,
            speechService: container.speechService
        )
    }
    
    // MARK: - Load Initial Data
    func loadInitialData() {
        Task {
            isLoading = true
            errorMessage = nil
            
            do {
                // Fetch historical data for chart
                historicalData = try await heatingRepository.fetchHistoricalData(days: 30)
                
                // Analyze efficiency
                currentInsight = try await analyzeEfficiencyUseCase.execute(days: 30)
                
                print("✅ Loaded \(historicalData.count) data points and insight")
            } catch {
                errorMessage = "Failed to load heating data"
                print("❌ Error loading data: \(error)")
            }
            
            isLoading = false
        }
    }
    
    // MARK: - Voice Input
    func startVoiceInput() {
        Task {
            let authorized = await speechService.requestAuthorization()
            guard authorized else {
                errorMessage = "Microphone permission denied"
                return
            }
            
            isListening = true
            recognizedText = ""
            aiResponse = nil
            errorMessage = nil
            
            do {
                try speechService.startListening { [weak self] partialText in
                    Task { @MainActor in
                        self?.recognizedText = partialText
                    }
                }
                
                try await Task.sleep(nanoseconds: 5_000_000_000)
                stopVoiceInput()
                
            } catch {
                isListening = false
                errorMessage = "Speech recognition failed"
                print("❌ Speech error: \(error)")
            }
        }
    }
    
    func stopVoiceInput() {
        let finalText = speechService.stopListening()
        isListening = false
        
        guard !finalText.isEmpty else {
            errorMessage = "No speech detected"
            return
        }
        
        recognizedText = finalText
        processVoiceCommand(text: finalText)
    }
    
    // MARK: - Process Voice Command
    func processVoiceCommand(text: String) {
        Task {
            isLoading = true
            errorMessage = nil
            
            let result = await processVoiceCommandUseCase.execute(text: text)
            aiResponse = result.response
            
            print("✅ Intent: \(result.intent), Confidence: \(String(format: "%.2f", result.confidence))")
            
            isLoading = false
        }
    }
    
    func processTextCommand(_ text: String) {
        recognizedText = text
        processVoiceCommand(text: text)
    }
}

// MARK: - Chart Metric
enum ChartMetric: String, CaseIterable {
    case cop = "COP"
    case energy = "Energy Usage"
    case temperature = "Temperature"
    
    var icon: String {
        switch self {
        case .cop: return "gauge.high"
        case .energy: return "bolt.fill"
        case .temperature: return "thermometer"
        }
    }
}
