//
//  ConversationView.swift
//  QuattSmartAdvisor
//
//  Created by Josevin Johny on 12/11/2025.
//

// Presentation/Views/Components/ConversationView.swift
import SwiftUI

struct ConversationView: View {
    let recognizedText: String
    let aiResponse: String?
    let isLoading: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Conversation")
                .font(.headline)
                .foregroundColor(.white)
            
            if !recognizedText.isEmpty {
                MessageBubble(text: recognizedText, isUser: true)
            }
            
            if let response = aiResponse {
                MessageBubble(text: response, isUser: false)
            }
            
            if isLoading {
                loadingIndicator
            }
        }
    }
    
    private var loadingIndicator: some View {
        HStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .cyan))
            Text("Thinking...")
                .foregroundColor(.gray)
        }
    }
}
