//
//  Router.swift
//  Appventure
//
//  Created by 조우현 on 4/24/25.
//

import Foundation
import Alamofire

enum RouterError: Error, LocalizedError {
    case invalidURLError
    case encodingError
    case network
    
    var errorDescription: String? {
        switch self {
        case .invalidURLError:
            "잘못된 URL"
        case .encodingError:
            "인코딩 에러"
        case .network:
            "요청 실패"
        }
    }
}

protocol Router: URLRequestConvertible {
    var endpoint: String { get }
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: HTTPHeaders { get }
    var params: Parameters { get }
    var encoding: ParameterEncoding? { get }
}

extension Router {
    
    func asURLRequest() throws -> URLRequest {
        guard let url = URL(string: endpoint) else {
            throw RouterError.invalidURLError
        }
        
        var request = URLRequest(url: url)
        request.method = method
        request.headers = headers
        
        if let encoding = encoding {
            do {
                return try encoding.encode(
                    request,
                    with: params
                )
            } catch {
                throw RouterError.encodingError
            }
        }
        
        return request
    }
}
