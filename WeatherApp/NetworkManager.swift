//
//  NetworkManager.swift
//  WeatherApp
//
//  Created by Phan Quyen on 08/08/2025.
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    
    private let session: URLSession
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30.0
        self.session = URLSession(configuration: config)
    }
    
    func performRequest(url: URL, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        let task = session.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(.requestFailed(error)))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(.invalidResponse))
                    return
                }
                
                guard 200...299 ~= httpResponse.statusCode else {
                    completion(.failure(.serverError(httpResponse.statusCode)))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }
                
                completion(.success(data))
            }
        }
        task.resume()
    }
}

enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case serverError(Int)
    case noData
    case decodingFailed
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "URL không hợp lệ"
        case .requestFailed(let error):
            return "Lỗi kết nối: \(error.localizedDescription)"
        case .invalidResponse:
            return "Phản hồi không hợp lệ"
        case .serverError(let code):
            return "Lỗi server: \(code)"
        case .noData:
            return "Không có dữ liệu"
        case .decodingFailed:
            return "Lỗi xử lý dữ liệu"
        }
    }
}
