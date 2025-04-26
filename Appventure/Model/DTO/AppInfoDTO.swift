//
//  AppInfoDTO.swift
//  Appventure
//
//  Created by 조우현 on 4/24/25.
//

import Foundation

// MARK: - AppInfoDTO
struct AppInfoDTO: Codable {
    let resultCount: Int
    let results: [InfoResultDTO]
}

// MARK: - InfoResultDTO
struct InfoResultDTO: Codable {
    let isGameCenterEnabled: Bool
    let features: [String]
    let supportedDevices: [String]
    let advisories: [String]
    let kind: String
    let artworkUrl512: String
    let screenshotUrls: [String]
    let artistViewURL: String
    let artworkUrl60, artworkUrl100: String
    let ipadScreenshotUrls: [String]
    let appletvScreenshotUrls: [String]
    let artistID: Int
    let artistName: String
    let genres: [String]
    let price: Double?
    let bundleID: String
    let currentVersionReleaseDate: String
    let sellerName: String
    let genreIDS: [String]
    let releaseNotes: String?
    let trackName: String
    let trackID: Int
    let isVppDeviceBasedLicensingEnabled: Bool
    let primaryGenreName: String
    let primaryGenreID: Int
    let version: String
    let wrapperType: String
    let currency: String
    let description: String
    let sellerURL: String?
    let minimumOSVersion: String
    let languageCodesISO2A: [String]
    let fileSizeBytes: String
    let formattedPrice: String?
    let userRatingCountForCurrentVersion: Int
    let trackContentRating: String
    let trackCensoredName: String
    let averageUserRatingForCurrentVersion, averageUserRating: Double
    let trackViewURL: String
    let contentAdvisoryRating: String
    let releaseDate: String
    let userRatingCount: Int

    enum CodingKeys: String, CodingKey {
        case isGameCenterEnabled, features, supportedDevices, advisories, kind, artworkUrl512, screenshotUrls
        case artistViewURL = "artistViewUrl"
        case artworkUrl60, artworkUrl100, ipadScreenshotUrls, appletvScreenshotUrls
        case artistID = "artistId"
        case artistName, genres, price
        case bundleID = "bundleId"
        case currentVersionReleaseDate, sellerName
        case genreIDS = "genreIds"
        case releaseNotes, trackName
        case trackID = "trackId"
        case isVppDeviceBasedLicensingEnabled, primaryGenreName
        case primaryGenreID = "primaryGenreId"
        case version, wrapperType, currency, description
        case sellerURL = "sellerUrl"
        case minimumOSVersion = "minimumOsVersion"
        case languageCodesISO2A, fileSizeBytes, formattedPrice, userRatingCountForCurrentVersion, trackContentRating, trackCensoredName, averageUserRatingForCurrentVersion, averageUserRating
        case trackViewURL = "trackViewUrl"
        case contentAdvisoryRating, releaseDate, userRatingCount
    }
}
