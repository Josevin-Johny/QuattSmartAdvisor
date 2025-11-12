//
//  AnalyzeHeatingEfficiencyUseCase.swift
//  QuattSmartAdvisor
//
//  Created by Josevin Johny on 12/11/2025.
//

// Domain/UseCases/AnalyzeHeatingEfficiencyUseCase.swift
import Foundation

protocol AnalyzeHeatingEfficiencyUseCase {
    func execute(days: Int) async throws -> HeatingInsight
}

class AnalyzeHeatingEfficiencyUseCaseImpl: AnalyzeHeatingEfficiencyUseCase {
    
    private let repository: HeatingRepository
    
    init(repository: HeatingRepository) {
        self.repository = repository
    }
    
    func execute(days: Int) async throws -> HeatingInsight {
        // Fetch historical data
        let data = try await repository.fetchHistoricalData(days: days)
        
        guard !data.isEmpty else {
            throw RepositoryError.dataNotFound
        }
        
        // Calculate metrics
        let averageCOP = calculateAverageCOP(from: data)
        let gasBackupPercentage = calculateGasBackupPercentage(from: data)
        let rating = determineEfficiencyRating(cop: averageCOP, gasBackup: gasBackupPercentage)
        let recommendations = generateRecommendations(
            cop: averageCOP,
            gasBackup: gasBackupPercentage,
            data: data
        )
        let savings = calculatePotentialSavings(recommendations: recommendations)
        
        let startDate = data.first?.date ?? Date()
        let endDate = data.last?.date ?? Date()
        
        return HeatingInsight(
            averageCOP: averageCOP,
            efficiencyRating: rating,
            gasBackupPercentage: gasBackupPercentage,
            recommendations: recommendations,
            potentialSavings: savings,
            period: DateInterval(start: startDate, end: endDate)
        )
    }
    
    // MARK: - Private Methods
    
    private func calculateAverageCOP(from data: [HeatingData]) -> Double {
        let validCOPs = data.map { $0.cop }.filter { $0 > 0 && $0 < 10 }
        guard !validCOPs.isEmpty else { return 0 }
        return validCOPs.reduce(0, +) / Double(validCOPs.count)
    }
    
    private func calculateGasBackupPercentage(from data: [HeatingData]) -> Double {
        let totalHeat = data.reduce(into: 0) { $0 + $1.heatDelivered }
        let totalGas = data.reduce(0) { $0 + $1.gasBoilerUsed }
        let total = totalHeat + totalGas
        guard total > 0 else { return 0 }
        return (totalGas / total) * 100
    }
    
    private func determineEfficiencyRating(cop: Double, gasBackup: Double) -> EfficiencyRating {
        // Optimal COP for heat pumps: 3.0 - 4.0
        // Gas backup should be minimal (< 20%)
        
        if cop >= 3.5 && gasBackup < 10 {
            return .excellent
        } else if cop >= 3.0 && gasBackup < 20 {
            return .good
        } else if cop >= 2.5 && gasBackup < 30 {
            return .average
        } else if cop >= 2.0 && gasBackup < 50 {
            return .poor
        } else {
            return .veryPoor
        }
    }
    
    private func generateRecommendations(
        cop: Double,
        gasBackup: Double,
        data: [HeatingData]
    ) -> [Recommendation] {
        var recommendations: [Recommendation] = []
        
        // Low COP recommendation
        if cop < 3.0 {
            recommendations.append(Recommendation(
                title: "Reduce Target Temperature",
                description: "Your COP is \(String(format: "%.1f", cop)), below optimal (3.0-4.0). Reduce temperature by 1-2°C to improve heat pump efficiency.",
                potentialSaving: 5.0,
                priority: .high
            ))
        }
        
        // High gas backup recommendation
        if gasBackup > 20 {
            recommendations.append(Recommendation(
                title: "Minimize Gas Boiler Usage",
                description: "Gas boiler is used \(String(format: "%.0f", gasBackup))% of the time. This indicates heat pump isn't meeting demand efficiently.",
                potentialSaving: 8.0,
                priority: .high
            ))
        }
        
        // Temperature optimization
        let avgRoomTemp = data.map { $0.roomTemp }.reduce(0, +) / Double(data.count)
        let avgOutsideTemp = data.map { $0.outsideTemp }.reduce(0, +) / Double(data.count)
        
        if avgRoomTemp - avgOutsideTemp < 2 {
            recommendations.append(Recommendation(
                title: "Unnecessary Heating Detected",
                description: "You're heating when outside temperature is already \(String(format: "%.0f", avgOutsideTemp))°C. Adjust your schedule.",
                potentialSaving: 15.0,
                priority: .high
            ))
        }
        
        // Maintenance check
        if cop < 2.5 {
            recommendations.append(Recommendation(
                title: "System Maintenance Needed",
                description: "Very low COP suggests potential system issues. Check for blocked outdoor unit or refrigerant levels.",
                potentialSaving: 10.0,
                priority: .high
            ))
        }
        
        return recommendations.sorted { $0.priority.rawValue > $1.priority.rawValue }
    }
    
    private func calculatePotentialSavings(recommendations: [Recommendation]) -> Double {
        return recommendations.reduce(0) { $0 + $1.potentialSaving }
    }
}
