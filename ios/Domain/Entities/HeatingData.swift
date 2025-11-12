//
//  HeatingData.swift
//  QuattSmartAdvisor
//
//  Created by Josevin Johny on 12/11/2025.
//

import Foundation

struct HeatingData {
  
  let date: Date
  let heatDelievered: Double
  let electricityUsed: Double
  let gasBoilerUsed: Double
  let estimatedGasUsage: Double
  let savings: Double
  let co2Saved: Double
  let outsideTemperature: Double
  let roomTemperature: Double
  
}


extension HeatingData {
  
  // MARK:- Calculations
  /// COP calcualtions
  var cop: Double {
    guard heatDelievered > 0 else { return 0 }
    return heatDelievered / electricityUsed
  }
  
  /// total energy used
  var totalEnergy: Double {
    return gasBoilerUsed + heatDelievered
  }
  
  /// Gas backup percentage
  var gasBackupSavings: Double {
    return estimatedGasUsage - gasBoilerUsed
  }
    
}

