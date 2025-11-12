//
//  ProductInfo.swift
//  QuattSmartAdvisor
//
//  Created by Josevin Johny on 12/11/2025.
//

// Domain/Entities/ProductInfo.swift
import Foundation

struct ProductInfo {
    let id: String
    let name: String
    let subtitle: String
    let imageURL: String?
    
    static let hybridHeatPump = ProductInfo(
        id: "hybrid-heat-pump",
        name: "Hybrid Heat Pump",
        subtitle: "Works with your boiler",
        imageURL: nil
    )
}
