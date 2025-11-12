//
//  HeatingRepository.swift
//  QuattSmartAdvisor
//
//  Created by Josevin Johny on 12/11/2025.
//

// Domain/Repositories/HeatingRepository.swift
import Foundation

protocol HeatingRepository {
    func fetchHistoricalData(days: Int) async throws -> [HeatingData]
    func fetchTodayData() async throws -> HeatingData?
}

enum RepositoryError: Error {
    case dataNotFound
    case invalidData
    case networkError(Error)
}
