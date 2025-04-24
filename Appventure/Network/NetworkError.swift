//
//  NetworkError.swift
//  Appventure
//
//  Created by 조우현 on 4/24/25.
//

import Foundation

enum NetworkError: Error {
    /// JSON 디코딩 실패
    case decoding(Error)
    /// 네트워크 자체 오류
    case transport(Error)
    
    /// 400 – 잘못된 요청
    case badRequest
    /// 401 – 인증 자격 없음
    case unauthorized
    /// 403 – 접근 차단
    case forbidden
    /// 404 – 존재하지 않는 엔드포인트
    case notFound
    /// 429 – 호출 한도 초과
    case tooManyRequests
    /// 500 – 서버 내부 오류
    case internalServerError
    /// 503 – 서비스 불가
    case serviceUnavailable
    
    /// 기타
    case unknown
    
    init(statusCode: Int) {
        switch statusCode {
        case 400: self = .badRequest
        case 401: self = .unauthorized
        case 403: self = .forbidden
        case 404: self = .notFound
        case 429: self = .tooManyRequests
        case 500: self = .internalServerError
        case 503: self = .serviceUnavailable
        default: self = .unknown
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .decoding(let error):
            return "응답 데이터를 해석할 수 없습니다. (\(error.localizedDescription))"
        case .transport(let error):
            return "네트워크 오류가 발생했습니다. (\(error.localizedDescription))"
        case .badRequest:
            return "잘못된 요청입니다."
        case .unauthorized:
            return "인증 정보가 유효하지 않습니다."
        case .forbidden:
            return "접근 권한이 없습니다."
        case .notFound:
            return "요청한 리소스를 찾을 수 없습니다."
        case .tooManyRequests:
            return "요청이 너무 많습니다. 잠시 후 다시 시도해주세요."
        case .internalServerError:
            return "서버 내부 오류가 발생했습니다."
        case .serviceUnavailable:
            return "서비스를 사용할 수 없습니다. 나중에 다시 시도해주세요."
        case .unknown:
            return "알 수 없는 오류가 발생했습니다."
        }
    }
}
