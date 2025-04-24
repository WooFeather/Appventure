//
//  NetworkManager.swift
//  Appventure
//
//  Created by 조우현 on 4/24/25.
//

import Foundation
import Alamofire

protocol NetworkManagerType {
    func fetchData<T: Decodable, U: Router>(_ api: U) async throws -> T
}

final class NetworkManager: NetworkManagerType {

    static let shared: NetworkManagerType = NetworkManager()
    private init() { }

    func fetchData<T: Decodable, U: Router>(_ api: U) async throws -> T {

        let dataTask = AF.request(api)
            .validate(statusCode: 200..<300)
            .serializingData()
        
        print(api.urlRequest?.url ?? "")

        let result = await dataTask.result

        switch result {
        case .success(let data):
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw NetworkError.decoding(error)
            }

        case .failure(let error):
            print("요청 실패: \(error.localizedDescription)")
            if let status = error.responseCode {
                throw NetworkError(statusCode: status)
            }

            throw NetworkError.transport(error)
        }
    }
}
