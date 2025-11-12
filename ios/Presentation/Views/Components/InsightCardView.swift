//
//  InsightCardView.swift
//  QuattSmartAdvisor
//
//  Created by Josevin Johny on 12/11/2025.
//

// Presentation/Views/Components/InsightCardView.swift
import SwiftUI

struct InsightCardView: View {
    let insight: HeatingInsight
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerSection
            
            if let topRec = insight.recommendations.first {
                Divider()
                    .background(Color.white.opacity(0.2))
                
                recommendationSection(topRec)
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
    
    private var headerSection: some View {
        HStack {
            
            VStack(alignment: .leading) {
                Text(insight.efficiencyRating.rawValue)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Avg COP: \(String(format: "%.2f", insight.averageCOP))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("€\(String(format: "%.0f", insight.potentialSavings))")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                Text("potential/week")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
    
    private func recommendationSection(_ rec: Recommendation) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(rec.title)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.cyan)
            
            Text(rec.description)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
    }
}
