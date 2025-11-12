//
//  MockDataGenerator.swift
//  QuattSmartAdvisor
//
//  Created by Josevin Johny on 12/11/2025.
//

// Data/DataSources/MockDataGenerator.swift
import Foundation

class MockDataGenerator {
    
    static func generateHistoricalData(days: Int) -> [HeatingData] {
        var data: [HeatingData] = []
        let calendar = Calendar.current
        
        for i in 0..<days {
            guard let date = calendar.date(byAdding: .day, value: -i, to: Date()) else { continue }
            
            // Simulate seasonal variation
          let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 0
            let seasonFactor = cos(Double(dayOfYear) * 2 * .pi / 365) * 0.5 + 0.5 // 0 to 1
            
            // Outside temperature varies by season (5°C to 25°C)
            let outsideTemp = 5 + (20 * (1 - seasonFactor)) + Double.random(in: -2...2)
            
            // Room temperature (target 21°C ± 1°C)
            let roomTemp = 21 + Double.random(in: -1...1)
            
            // Heat delivered depends on temperature difference
            let tempDiff = max(0, roomTemp - outsideTemp)
            let baseHeat = tempDiff * Double.random(in: 1.5...2.5)
            let heatDelivered = max(10, min(60, baseHeat))
            
            // Electricity used (COP varies 2.5 to 4.0)
            let cop = Double.random(in: 2.5...4.0)
            let electricityUsed = heatDelivered / cop
            
            // Gas boiler kicks in when heat pump struggles (cold days)
            let gasBoilerUsed: Double
            if outsideTemp < 10 {
                // More gas backup on very cold days
                gasBoilerUsed = Double.random(in: 5...25)
            } else {
                gasBoilerUsed = Double.random(in: 0...5)
            }
            
            // Estimated gas usage in m³
            let estimatedGasUsage = gasBoilerUsed * 0.1
            
            // Savings calculation (vs traditional boiler)
            let traditionalCost = (heatDelivered + gasBoilerUsed) * 0.08 // €0.08/kWh for gas
            let actualCost = (electricityUsed * 0.25) + (gasBoilerUsed * 0.08) // €0.25/kWh for electricity
            let savings = traditionalCost - actualCost
            
            // CO2 saved (heat pump is cleaner)
            let co2Saved = (traditionalCost - actualCost) * 0.2 // kg CO2
            
            data.append(HeatingData(
                date: date,
                heatDelivered: heatDelivered,
                electricityUsed: electricityUsed,
                gasBoilerUsed: gasBoilerUsed,
                estimatedGasUsage: estimatedGasUsage,
                savings: savings,
                co2Saved: co2Saved,
                outsideTemp: outsideTemp,
                roomTemp: roomTemp
            ))
        }
        
        return data.reversed() // Chronological order
    }
    
    static func generateTodayData() -> HeatingData {
        let today = Date()
        
        return HeatingData(
            date: today,
            heatDelivered: 42.0,
            electricityUsed: 15.0,
            gasBoilerUsed: 8.0,
            estimatedGasUsage: 0.8,
            savings: 2.5,
            co2Saved: 0.5,
            outsideTemp: 12.0,
            roomTemp: 21.0
        )
    }
}
