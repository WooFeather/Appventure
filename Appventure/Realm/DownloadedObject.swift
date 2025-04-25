//
//  DownloadedObject.swift
//  Appventure
//
//  Created by 조우현 on 4/26/25.
//

import Foundation
import RealmSwift

// TODO: 얼마나 다운로드 됐는지 진행률도 저장? (UserDefaults)
final class DownloadedObject: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: String
    @Persisted var createdAt: Date = Date()
}
