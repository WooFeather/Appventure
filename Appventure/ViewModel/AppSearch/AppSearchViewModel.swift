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
    }
    
    struct Output {
        var results: [InfoResultEntity] = []
        var isLoading: Bool = false
    }
}

// MARK: - Action
extension AppSearchViewModel {
    enum Action {
        case search
    }
    
    func action(_ action: Action) {
        switch action {
        case .search:
            input.searchTapped.send(())
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
                Task {
                    do {
                        try await self?.fetchSearchData(for: term)
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
    func fetchSearchData(for term: String, offset: Int = 0) async throws {
        output.isLoading = true
        
        do {
            let response = try await repository.search(term: term, offset: offset)
            output.results = response.results
        } catch {
            output.results = []
            throw error
        }
        
        output.isLoading = false
    }
}
