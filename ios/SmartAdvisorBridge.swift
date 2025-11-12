//
//  SmartAdvisorBridge.swift
//  QuattSmartAdvisor
//
//  Created by Josevin Johny on 12/11/2025.
//

import Foundation
import UIKit
import SwiftUI

@objc(SmartAdvisorModule)
class SmartAdvisorModule: NSObject {
    
  @objc
  func present() {
      DispatchQueue.main.async {
          guard let rootVC = self.getRootViewController() else {
              print("Could not find root view controller")
              return
          }
          
          // Use new SmartAdvisorView instead of placeholder
        if #available(iOS 16.0, *) {
          let advisorView = SmartAdvisorView()
          let hostingController = UIHostingController(rootView: advisorView)
          hostingController.modalPresentationStyle = .fullScreen
          
          rootVC.present(hostingController, animated: true)
        }
      }
  }
    
    private func getRootViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            return nil
        }
        
        var topController = rootViewController
        while let presented = topController.presentedViewController {
            topController = presented
        }
        
        return topController
    }
    
    @objc
    static func requiresMainQueueSetup() -> Bool {
        return true
    }
}

struct SmartAdvisorPlaceholder: View {
    @Environment(\.dismiss) var dismiss
    @State private var userInput = ""
    @State private var prediction = ""
    @State private var confidence = ""
    @State private var isProcessing = false
    
    private let classifier = IntentClassifier()
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    Spacer()
                    Text("Smart Advisor")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                    Color.clear.frame(width: 30)
                }
                .padding()
                
                Spacer()
                
                // Title
                Text("🧠 CoreML Intent Classifier")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Test the AI model")
                    .foregroundColor(.gray)
                
                // Input field
                TextField("Type your question...", text: $userInput)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 40)
                
                // Buttons
                HStack(spacing: 16) {
                    // Test Smart Advisor Button
                    Button(action: testSmartAdvisor) {
                        HStack {
                            Image(systemName: "brain.head.profile")
                            Text("Smart Advisor")
                        }
                        
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.cyan)
                        .cornerRadius(12)
                    }
                    
                    // Classify Button
                    Button(action: classifyText) {
                        HStack {
                            Image(systemName: "text.magnifyingglass")
                            Text("Classify")
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 40)
                
                // Processing indicator
                if isProcessing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .cyan))
                        .scaleEffect(1.5)
                }
                
                // Results
                if !prediction.isEmpty {
                    VStack(spacing: 16) {
                        // Intent Result
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Intent:")
                                    .foregroundColor(.gray)
                                Text(prediction)
                                    .foregroundColor(.cyan)
                                    .fontWeight(.bold)
                            }
                            
                            HStack {
                                Text("Confidence:")
                                    .foregroundColor(.gray)
                                Text(confidence)
                                    .foregroundColor(.green)
                                    .fontWeight(.bold)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        
                        // Smart Response
                        if !smartResponse.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Smart Advisor Response:")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                                
                                Text(smartResponse)
                                    .foregroundColor(.white)
                                    .font(.body)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.cyan.opacity(0.2))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 40)
                }
                
                Spacer()
                
                // Examples
                VStack(alignment: .leading, spacing: 8) {
                    Text("Try these:")
                        .foregroundColor(.gray)
                        .font(.caption)
                    
                    ForEach([
                        "How efficient is my heating?",
                        "What will it cost next week?",
                        "Should I adjust my settings?",
                        "What's my current status?"
                    ], id: \.self) { example in
                        Button(action: {
                            userInput = example
                        }) {
                            Text(example)
                                .font(.caption)
                                .foregroundColor(.cyan)
                                .padding(.vertical, 4)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 40)
            }
        }
    }
    
    @State private var smartResponse = ""
    
    // Test Smart Advisor - Full flow
    private func testSmartAdvisor() {
        guard !userInput.isEmpty else {
            userInput = "How efficient is my heating?"
          return
        }
        
        isProcessing = true
        prediction = ""
        confidence = ""
        smartResponse = ""
        
        // Simulate processing delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Classify intent with CoreML
            let (command, conf) = classifier.classifyIntent(from: userInput)
            
            prediction = formatIntent(command)
            confidence = String(format: "%.1f%%", conf * 100)
            
            // Generate smart response based on intent
            smartResponse = generateResponse(for: command, confidence: conf)
            
            isProcessing = false
        }
    }
    
    // Simple classify - just show intent
    private func classifyText() {
        guard !userInput.isEmpty else { return }
        
        isProcessing = true
        smartResponse = ""
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let (command, conf) = classifier.classifyIntent(from: userInput)
            
            prediction = formatIntent(command)
            confidence = String(format: "%.1f%%", conf * 100)
            
            isProcessing = false
        }
    }
    
    private func formatIntent(_ command: VoiceCommand) -> String {
        switch command {
        case .analyzeEfficiency:
            return "Analyze Efficiency"
        case .predictCosts:
            return "Predict Costs"
        case .recommendSettings:
            return "Recommend Settings"
        case .checkStatus:
            return "Check Status"
        case .unknown:
            return "Unknown Intent"
        }
    }
    
    private func generateResponse(for command: VoiceCommand, confidence: Double) -> String {
        // Low confidence
        guard confidence > 0.5 else {
            return "I'm not sure what you mean. Try asking about efficiency, costs, or settings."
        }
        
        switch command {
        case .analyzeEfficiency:
            return """
            Your system is running at COP 2.8. That's below optimal (3.0-4.0 for heat pumps).
            
            Recommendation: Reduce temperature by 1°C to improve heat pump efficiency.
            
            Potential savings: €5/week
            """
            
        case .predictCosts:
            return """
            Based on weather forecast (dropping to 15°C), next week will cost approximately €8.50.
            
            That's €3 more than this week due to colder temperatures.
            
            Tip: Pre-heat during off-peak hours to save money.
            """
            
        case .recommendSettings:
            return """
            Recommended settings:
            • Day: 20°C (8am-6pm)
            • Evening: 21°C (6pm-11pm)
            • Night: 18°C (11pm-8am)
            
            This optimizes your heat pump efficiency while maintaining comfort.
            
            Expected savings: €4/week
            """
            
        case .checkStatus:
            return """
            Your heating system is operating normally.
            
            Current status:
            • COP: 3.2 (Good)
            • Heat pump running efficiently
            • No gas backup needed today
            
            System health: ✅ Excellent
            """
            
        case .unknown:
            return "I can help you with efficiency analysis, cost predictions, or settings recommendations. What would you like to know?"
        }
    }
}
