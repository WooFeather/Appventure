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
        let fetchDownloaded = PassthroughSubject<Void, Never>()
        let deleteApp = PassthroughSubject<String, Never>()
        let searchQuery = CurrentValueSubject<String, Never>("")
    }
    
    struct Output {
        var downloadedApps: [DownloadedAppItem] = []
        var filteredDownloadedApps: [DownloadedAppItem] = []
        var isLoading: Bool = false
    }
}

// MARK: - Action
extension MyAppViewModel {
    enum Action {
        case fetchDownloaded
        case deleteApp(String)
    }
    
    func action(_ action: Action) {
        switch action {
        case .fetchDownloaded:
            input.fetchDownloaded.send(())
        case .deleteApp(let id):
            input.deleteApp.send(id)
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
        
        input.deleteApp
            .sink { [weak self] id in
                self?.realmRepo.delete(by: id)
            }
            .store(in: &cancellables)
        
        input.searchQuery
            .sink { [weak self] query in
                self?.applyFilter(query: query)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Function
extension MyAppViewModel {
    @MainActor
    private func fetchDownloadedApps() async throws {
        output.isLoading = true
        
        // 전체 realm의 데이터가 아닌 state가 completed인 데이터들만 보여줌
        let downloadedObjects = realmRepo.fetchAll()
            .filter { $0.state == .completed }
        let idDateMap = Dictionary(uniqueKeysWithValues:
                                    downloadedObjects.map { ($0.id, $0.createdAt) })
        
        let ids = downloadedObjects
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
            applyFilter(query: input.searchQuery.value)
        } catch {
            output.downloadedApps = []
            throw error
        }
        
        output.isLoading = false
    }
    
    private func applyFilter(query: String) {
        let trimmingQuery = query.trimmingCharacters(in: .whitespaces)
        
        output.filteredDownloadedApps = trimmingQuery.isEmpty
            ? output.downloadedApps
            : output.downloadedApps.filter {
                $0.info.name.localizedCaseInsensitiveContains(query)
            }
    }
}
