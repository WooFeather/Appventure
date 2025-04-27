//
//  RealmRepository.swift
//  Appventure
//
//  Created by 조우현 on 4/26/25.
//

import Foundation
import RealmSwift
import Combine

protocol RealmRepositoryType {
    func getFileURL()
    func fetchAll() -> [DownloadedObject]
    func save(_ downloaded: DownloadedObject)
    func delete(by id: String)
    func getAllDownloadedIDs() -> [String]
    func handleAppWillTerminate()
    func startDownload(appId: String)
    func pauseDownload(appId: String)
    func resumeDownload(appId: String)
    func pauseAllDownloadsOnNetworkDisconnect()
}

final class RealmRepository: RealmRepositoryType {
    static let shared = RealmRepository()
    private let realm = try! Realm()
    
    private var completeCancellable: AnyCancellable?
    
    private init() {
        // 앱 런치 시점에 1초마다 모든 다운로드 상태 점검하는 글로벌 타이머 추가
        completeCancellable = Timer
            .publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.completeAllDownloadsIfNeeded()
            }
    }
    
    func getFileURL() {
        print(realm.configuration.fileURL ?? "URL 찾을 수 없음")
    }
    
    func fetchAll() -> [DownloadedObject] {
        Array(realm.objects(DownloadedObject.self))
    }
    
    func save(_ downloaded: DownloadedObject) {
        do {
            try realm.write {
                realm.add(downloaded, update: .modified)
            }
        } catch {
            print("❌ Realm save 오류:", error)
        }
    }
    
    // 실제로 삭제하는게 아닌, 삭제 처리만
    func delete(by id: String) {
        guard let object = realm.object(ofType: DownloadedObject.self, forPrimaryKey: id) else { return }
        do {
            try realm.write {
                object.state = .deleted
                object.isDeleted = true
            }
        } catch {
            print("❌ Realm delete 오류:", error)
        }
    }
    
    func getAllDownloadedIDs() -> [String] {
        let realm = try! Realm()
        return realm.objects(DownloadedObject.self)
            .filter { $0.isDeleted == false }
            .map { $0.id }
    }
    
    // MARK: - 다운로드 로직
    func handleAppWillTerminate() {
        let list = realm.objects(DownloadedObject.self)
            .filter("stateRaw == %@", DownloadState.downloading.rawValue)
        
        do {
            try realm.write {
                list.forEach { object in
                    if let end = object.expectedEndDate {
                        object.remainingTime = max(0, end.timeIntervalSinceNow)
                    }
                    object.expectedEndDate = nil
                    object.state = .paused
                }
            }
        } catch {
            print("❌ Realm handleAppWillTerminate 오류:", error)
        }
    }
    
    func startDownload(appId: String) {
        let object = realm.object(ofType: DownloadedObject.self, forPrimaryKey: appId)
            ?? DownloadedObject(value: ["id": appId])

        do {
            try realm.write {
                if object.realm == nil {
                    realm.add(object)
                    object.createdAt = Date()
                } else if object.state == .deleted {
                    object.createdAt = Date() // 다시 받기 할 때 날짜 갱신
                }
                object.state = .downloading
                object.expectedEndDate = Date().addingTimeInterval(30)
                object.isDeleted = false
            }
        } catch {
            print("❌ Realm startDownload 오류:", error)
        }
    }
    
    func pauseDownload(appId: String) {
        guard let object = realm.object(ofType: DownloadedObject.self, forPrimaryKey: appId),
              object.state == .downloading,
              let end = object.expectedEndDate
        else { return }
        
        let remaining = max(0, end.timeIntervalSinceNow)
        do {
            try realm.write {
                object.remainingTime = remaining
                object.expectedEndDate = nil
                object.state = .paused
            }
        } catch {
            print("❌ Realm pauseDownload 오류:", error)
        }
    }
    
    func resumeDownload(appId: String) {
        guard let object = realm.object(ofType: DownloadedObject.self, forPrimaryKey: appId),
              object.state == .paused
        else { return }
        
        do {
            try realm.write {
                object.expectedEndDate = Date().addingTimeInterval(object.remainingTime)
                object.state = .downloading
            }
        } catch {
            print("❌ Realm resumeDownload 오류:", error)
        }
    }
    
    private func completeAllDownloadsIfNeeded() {
        let now = Date()
        let list = realm.objects(DownloadedObject.self)
            .filter("stateRaw == %@", DownloadState.downloading.rawValue)
        
        guard !list.isEmpty else { return }
        do {
            try realm.write {
                for object in list {
                    if let end = object.expectedEndDate, now >= end {
                        object.state = .completed
                        object.expectedEndDate = nil
                        object.remainingTime = 0
                    }
                }
            }
        } catch {
            print("❌ Realm completeAllDownloads 오류:", error)
        }
    }
    
    // 네트워크 끊김 시 호출해서 모든 .downloading 레코드를 .paused로 전환
    func pauseAllDownloadsOnNetworkDisconnect() {
        let list = realm.objects(DownloadedObject.self)
            .filter("stateRaw == %@", DownloadState.downloading.rawValue)
        
        guard !list.isEmpty else { return }
        do {
            try realm.write {
                list.forEach { object in
                    if let end = object.expectedEndDate {
                        object.remainingTime = max(0, end.timeIntervalSinceNow)
                    }
                    object.expectedEndDate = nil
                    object.state = .paused
                }
            }
        } catch {
            print("❌ pauseAllDownloads 오류:", error)
        }
    }
}
