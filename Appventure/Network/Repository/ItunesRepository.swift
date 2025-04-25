//
//  ItunesRepository.swift
//  Appventure
//
//  Created by 조우현 on 4/24/25.
//

import Foundation

protocol ItunesRepositoryType {
    func search(term: String, offset: Int) async throws -> AppInfoEntity
    func lookup(ids: [String]) async throws -> AppInfoEntity
}

final class ItunesRepository: ItunesRepositoryType {
    static let shared: ItunesRepositoryType = ItunesRepository()
    private let networkManager: NetworkManagerType = NetworkManager.shared
    
    private init() { }
    
    func search(term: String, offset: Int) async throws -> AppInfoEntity {
        do {
            let result: AppInfoDTO = try await networkManager.fetchData(ItunesRouter.search(term: term, offset: offset))
            return result.toEntity()
        } catch {
            print("error: \(error)")
            throw error
        }
    }
    
    func lookup(ids: [String]) async throws -> AppInfoEntity {
        do {
            let result: AppInfoDTO = try await networkManager.fetchData(ItunesRouter.lookup(ids: ids))
            return result.toEntity()
        } catch {
            print("error: \(error)")
            throw error
        }
    }
}
