//
//  AppSearchViewModel.swift
//  Appventure
//
//  Created by 조우현 on 4/25/25.
//

import Foundation
import Combine

final class AppSearchViewModel: ViewModelType {
    private let repository: ItunesRepositoryType
    var cancellables: Set<AnyCancellable>
    var input: Input
    @Published var output: Output
    
    init(
        repository: ItunesRepositoryType,
        cancellables: Set<AnyCancellable> = Set<AnyCancellable>(),
        input: Input = Input(),
        output: Output = Output()
    ) {
        self.repository = repository
        self.cancellables = cancellables
        self.input = input
        self.output = output
        transform()
    }
    
    struct Input {
        var term: String = ""
        let searchTapped = PassthroughSubject<Void, Never>()
        let loadMore = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        var results: [InfoResultEntity] = []
        var isLoading: Bool = false
        var isLoadingMore: Bool = false
        var currentOffset: Int = 0
        var hasMoreResults: Bool = true
    }
}

// MARK: - Action
extension AppSearchViewModel {
    enum Action {
        case search
        case loadMore
    }
    
    func action(_ action: Action) {
        switch action {
        case .search:
            input.searchTapped.send(())
        case .loadMore:
            input.loadMore.send(())
        }
    }
}

// MARK: - Transform
extension AppSearchViewModel {
    func transform() {
        input.searchTapped
            .map { [weak self] in
                self?.input.term.trimmingCharacters(in: .whitespaces) ?? ""
            }
            .removeDuplicates()
            .filter { !$0.isEmpty }
            .sink { [weak self] term in
                guard let self = self else { return }
                
                Task { @MainActor in
                    do {
                        self.output.currentOffset = 0
                        self.output.hasMoreResults = true
                        try await self.fetchSearchData(for: term, offset: 0, isLoadingMore: false)
                    } catch {
                        throw error
                    }
                }
            }
            .store(in: &cancellables)
        
        // Add handler for loading more results
        input.loadMore
            .filter { [weak self] in
                guard let self = self else { return false }
                return !self.output.isLoadingMore && self.output.hasMoreResults
            }
            .sink { [weak self] _ in
                guard let self = self, !self.input.term.isEmpty else { return }
                
                Task {
                    do {
                        let nextOffset = self.output.currentOffset + 20
                        try await self.fetchSearchData(for: self.input.term, offset: nextOffset, isLoadingMore: true)
                    } catch {
                        throw error
                    }
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Function
@MainActor
extension AppSearchViewModel {
    func fetchSearchData(for term: String, offset: Int = 0, isLoadingMore: Bool = false) async throws {
        if isLoadingMore {
            output.isLoadingMore = true
        } else {
            output.isLoading = true
        }
        
        do {
            let response = try await repository.search(term: term, offset: offset)
            
            if isLoadingMore {
                let existingIds = Set(output.results.map { $0.id })
                let newResults = response.results.filter { !existingIds.contains($0.id) }
                
                // Append new unique results
                output.results.append(contentsOf: newResults)
                
                if newResults.isEmpty && !response.results.isEmpty {
                    output.isLoadingMore = false
                    try await fetchSearchData(for: term, offset: offset + 20, isLoadingMore: true)
                    return
                }
                
                output.hasMoreResults = !newResults.isEmpty
            } else {
                output.results = response.results
                output.hasMoreResults = !response.results.isEmpty
            }
            
            output.currentOffset = offset
        } catch {
            if !isLoadingMore {
                output.results = []
            }
            output.hasMoreResults = false
            throw error
        }
        
        if isLoadingMore {
            output.isLoadingMore = false
        } else {
            output.isLoading = false
        }
    }
}
