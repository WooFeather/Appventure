//
//  RealmRepository.swift
//  Appventure
//
//  Created by 조우현 on 4/26/25.
//

import Foundation
import RealmSwift

protocol RealmRepositoryType {
    func getFileURL()
    func fetchAll() -> [DownloadedObject]
    func save(_ downloaded: DownloadedObject)
    func delete(by id: String)
}

final class RealmRepository: RealmRepositoryType {
    static let shared = RealmRepository()
    private let realm = try! Realm()
    
    private init() { }
    
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
    
    func delete(by id: String) {
        guard let object = realm.object(ofType: DownloadedObject.self, forPrimaryKey: id) else { return }
        do {
            try realm.write {
                realm.delete(object)
            }
        } catch {
            print("❌ Realm delete 오류:", error)
        }
    }
}
