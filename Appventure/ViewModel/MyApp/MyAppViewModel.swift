//
//  MyAppViewModel.swift
//  Appventure
//
//  Created by 조우현 on 4/26/25.
//

import Foundation
import Combine

final class MyAppViewModel: ViewModelType {
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
        var fetchDownloaded = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        var downloadedApps: [InfoResultEntity] = []
        var isLoading: Bool = false
    }
}

// MARK: - Action
extension MyAppViewModel {
    enum Action {
        case fetchDownloaded
    }
    
    func action(_ action: Action) {
        switch action {
        case .fetchDownloaded:
            input.fetchDownloaded.send(())
        }
    }
}

// MARK: - Transform
extension MyAppViewModel {
    func transform() {
        
    }
}

// MARK: - Function
@MainActor
extension MyAppViewModel {
    private func fetchDownloadedApps() async throws {
        output.isLoading = true
        
        // realm에서 불러오기
        
        output.isLoading = false
    }
}
