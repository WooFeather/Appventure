//
//  AppDetailViewModel.swift
//  Appventure
//
//  Created by 조우현 on 4/25/25.
//

import Foundation
import Combine

final class AppDetailViewModel: ViewModelType {
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
        var fetchApp = PassthroughSubject<Int, Never>()
    }
    
    struct Output {
        var app: InfoResultEntity? = nil
        var isLoading: Bool = false
    }
}

// MARK: - Action
extension AppDetailViewModel {
    enum Action {
        case fetchApp(Int)
    }
    
    func action(_ action: Action) {
        switch action {
        case .fetchApp(let id):
            input.fetchApp.send(id)
        }
    }
}

// MARK: - Tranform
extension AppDetailViewModel {
    func transform() {
        input.fetchApp
            .sink { [weak self] id in
                Task {
                    do {
                        try await self?.fetchApp(id: id)
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
extension AppDetailViewModel {
    private func fetchApp(id: Int) async throws {
        output.isLoading = true
        
        do {
            let response = try await repository.lookup(id: id).results
            output.app = response.first
        } catch {
            output.app = nil
            throw error
        }
        
        output.isLoading = false
    }
}
