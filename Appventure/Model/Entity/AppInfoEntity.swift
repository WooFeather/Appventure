//
//  AppInfoEntity.swift
//  Appventure
//
//  Created by 조우현 on 4/24/25.
//

import Foundation

struct AppInfoEntity {
    let resultCount: Int
    let results: [InfoResultEntity]
}

struct InfoResultEntity {
    let id: String // trackID
    
    let name: String // trackName
    let iconUrlLarge: String // artworkUrl512
    let iconUrlSmall: String // artworkUrl100
    let genres: [String]
    let primaryGenreName: String
    let minimumVersion: String // minimumOsVersion
    let corpName: String // artistName
    let price: String // formattedPrice
    
    let screenShotsUrls: [String]
    let age: String // trackContentRating
    let languages: [String] // languageCodesISO2A
    let description: String
    
    let releaseNotes: String
    let currentReleaseDate: String // currentVersionReleaseDate
    let version: String
}

extension AppInfoDTO {
    func toEntity() -> AppInfoEntity {
        return AppInfoEntity(
            resultCount: self.resultCount,
            results: self.results.map {
                InfoResultEntity(
                    id: "\($0.trackID)",
                    name: $0.trackName,
                    iconUrlLarge: $0.artworkUrl512,
                    iconUrlSmall: $0.artworkUrl100,
                    genres: $0.genres,
                    primaryGenreName: $0.primaryGenreName,
                    minimumVersion: $0.minimumOSVersion,
                    corpName: $0.artistName,
                    price: $0.formattedPrice ?? "가격 정보 없음",
                    screenShotsUrls: $0.screenshotUrls,
                    age: $0.trackContentRating,
                    languages: $0.languageCodesISO2A,
                    description: $0.description,
                    releaseNotes: $0.releaseNotes ?? "",
                    currentReleaseDate: $0.currentVersionReleaseDate,
                    version: $0.version
                )
            }
        )
    }
}
