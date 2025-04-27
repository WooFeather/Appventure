//
//  AppSearchViewModel.swift
//  Appventure
//
//  Created by 조우현 on 4/25/25.
//

import Foundation
import Combine

final class AppSearchViewModel: ViewModelType {
    private let networkRepo: ItunesRepositoryType
    private let realmRepo: RealmRepositoryType
    var cancellables: Set<AnyCancellable>
    var input: Input
    @Published var output: Output
    
    init(
        networkRepo: ItunesRepositoryType,
        realmRepo: RealmRepositoryType,
        cancellables: Set<AnyCancellable> = Set<AnyCancellable>(),
        input: Input = Input(),
        output: Output = Output()
    ) {
        self.networkRepo = networkRepo
        self.realmRepo = realmRepo
        self.cancellables = cancellables
        self.input = input
        self.output = output
        transform()
    }
    
    struct Input {
        var term: String = ""
        let searchTapped = PassthroughSubject<Void, Never>()
        let loadMore = PassthroughSubject<Void, Never>()
        let clearResults = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        var results: [InfoResultEntity] = []
        var isLoading: Bool = false
        var isLoadingMore: Bool = false
        var currentOffset: Int = 0
        var hasMoreResults: Bool = true
        var isDownloaded: Bool = false
        var downloadedIDs: Set<String> = []
        var hasSearched: Bool = false
    }
}

// MARK: - Action
extension AppSearchViewModel {
    enum Action {
        case search
        case loadMore
        case clearResults
    }
    
    func action(_ action: Action) {
        switch action {
        case .search:
            input.searchTapped.send(())
        case .loadMore:
            input.loadMore.send(())
        case .clearResults:
            input.clearResults.send(())
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
                
                self.output.hasSearched = true
            }
            .store(in: &cancellables)
        
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
        
        input.clearResults
            .sink { [weak self] _ in
                self?.clearResults()
                self?.output.hasSearched = false
            }
            .store(in: &cancellables)
    }
}

// MARK: - Function

extension AppSearchViewModel {
    @MainActor
    func fetchSearchData(for term: String, offset: Int = 0, isLoadingMore: Bool = false) async throws {
        if isLoadingMore {
            output.isLoadingMore = true
        } else {
            output.isLoading = true
        }
        
        do {
            let response = try await networkRepo.search(term: term, offset: offset)
            
            if isLoadingMore {
                let existingIds = Set(output.results.map { $0.id })
                let newResults = response.results.filter { !existingIds.contains($0.id) }
                
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
            
            let allDownloadedIDs = realmRepo.getAllDownloadedIDs()
            output.downloadedIDs = Set(allDownloadedIDs)
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
    
    func clearResults() {
        output.results.removeAll()
        output.currentOffset = 0
        output.hasMoreResults = false
    }
}

// MARK: - ViewState
extension AppSearchViewModel {
    var viewState: SearchViewState {
        if output.isLoading { return .searching }
        if !output.hasSearched { return .initial }
        if output.results.isEmpty { return .notFound }
        return .found
    }
}
