//
//  HeatingData.swift
//  QuattSmartAdvisor
//
//  Created by Josevin Johny on 12/11/2025.
//

import Foundation

struct HeatingData : Identifiable {
  
  let id = UUID() 
  let date: Date
  let heatDelivered: Double
  let electricityUsed: Double
  let gasBoilerUsed: Double
  let estimatedGasUsage: Double
  let savings: Double
  let co2Saved: Double
  let outsideTemp: Double
  let roomTemp: Double
  
}


extension HeatingData {
  
  // MARK:- Calculations
  /// COP calcualtions
  var cop: Double {
    guard heatDelivered > 0 else { return 0 }
    return heatDelivered / electricityUsed
  }
  
  /// total energy used
  var totalEnergy: Double {
    return gasBoilerUsed + heatDelivered
  }
  
  /// Gas backup percentage
  var gasBackupSavings: Double {
    return estimatedGasUsage - gasBoilerUsed
  }
    
}

