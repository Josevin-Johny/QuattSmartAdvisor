//
//  VoiceInputView.swift
//  QuattSmartAdvisor
//
//  Created by Josevin Johny on 12/11/2025.
//

// Presentation/Views/Components/VoiceInputView.swift
import SwiftUI

struct VoiceInputView: View {
    let isListening: Bool
    let errorMessage: String?
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
            Button(action: onTap) {
                micButton
            }
            
            Text(isListening ? "Listening..." : "Tap to ask")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.black)
    }
    
    private var micButton: some View {
        ZStack {
            Circle()
                .fill(isListening ? Color.red : Color.cyan)
                .frame(width: 70, height: 70)
                .scaleEffect(isListening ? 1.1 : 1.0)
                .animation(
                    isListening ? .easeInOut(duration: 0.8).repeatForever(autoreverses: true) : .default,
                    value: isListening
                )
            
            Image(systemName: isListening ? "stop.fill" : "mic.fill")
                .font(.title)
                .foregroundColor(.white)
        }
    }
}
