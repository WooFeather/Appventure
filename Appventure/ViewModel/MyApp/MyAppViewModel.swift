//
//  MyAppViewModel.swift
//  Appventure
//
//  Created by 조우현 on 4/26/25.
//

import Foundation
import Combine


// MARK: - DownloadedAppItem
struct DownloadedAppItem: Identifiable {
    let id: String
    let info: InfoResultEntity
    let date: Date
}

// MARK: - ViewModel
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
        var downloadedApps: [DownloadedAppItem] = []
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
        input.fetchDownloaded
            .sink { [weak self] _ in
                Task {
                    do {
                        try await self?.fetchDownloadedApps()
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
extension MyAppViewModel {
    private func fetchDownloadedApps() async throws {
        output.isLoading = true
        
        let realmObjects = realmRepo.fetchAll()
        let idDateMap = Dictionary(uniqueKeysWithValues:
            realmObjects.map { ($0.id, $0.createdAt) })
        
        let ids = realmObjects
            .sorted(by: { $0.createdAt > $1.createdAt })
            .map(\.id)
        
        do {
            let response = try await networkRepo.lookup(ids: ids)
            
            let items: [DownloadedAppItem] = ids.compactMap { id in
                guard let info = response.results.first(where: { $0.id == id }),
                      let date = idDateMap[id] else { return nil }
                return DownloadedAppItem(id: id, info: info, date: date)
            }
            output.downloadedApps = items
        } catch {
            output.downloadedApps = []
            throw error
        }
        
        output.isLoading = false
    }
}
