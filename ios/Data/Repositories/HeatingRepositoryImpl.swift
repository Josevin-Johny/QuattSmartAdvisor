//
//  Repositories.swift
//  QuattSmartAdvisor
//
//  Created by Josevin Johny on 12/11/2025.
//

// Data/Repositories/HeatingRepositoryImpl.swift
import Foundation

class HeatingRepositoryImpl: HeatingRepository {
    
    // Simulate network delay
    private let simulateDelay: Bool
    
    init(simulateDelay: Bool = true) {
        self.simulateDelay = simulateDelay
    }
    
    func fetchHistoricalData(days: Int) async throws -> [HeatingData] {
        // Simulate network delay
        if simulateDelay {
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        }
        
        print("Fetching \(days) days of historical data...")
        
        let data = MockDataGenerator.generateHistoricalData(days: days)
        
        print("Fetched \(data.count) data points")
        
        return data
    }
    
    func fetchTodayData() async throws -> HeatingData? {
        // Simulate network delay
        if simulateDelay {
            try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        }
        
        print("Fetching today's data...")
        
        let data = MockDataGenerator.generateTodayData()
        
        print("Fetched today's data: COP \(String(format: "%.2f", data.cop))")
        
        return data
    }
}
