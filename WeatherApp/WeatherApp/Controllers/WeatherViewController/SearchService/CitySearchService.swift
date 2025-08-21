//
//  CitySearchService.swift
//  WeatherApp
//
//  Created by Phan Quyen on 20/08/2025.
//

import Foundation

class CitySearchService {
    static let shared = CitySearchService()
    
    private let baseURL = "https://api.openweathermap.org/geo/1.0/direct"
    private let networkManager = NetworkManager.shared
    
    private var apiKey: String? {
        return Bundle.main.infoDictionary?["OpenWeatherMapAPIKey"] as? String
    }
    
    private init() {}
    
    func searchCities(query: String, completion: @escaping (Result<[CitySearchResult], WeatherAPIError>) -> Void) {
        guard !query.isEmpty else {
            completion(.success([]))
            return
        }
        
        guard let apiKey = apiKey, !apiKey.isEmpty else {
            completion(.failure(.invalidAPIKey))
            return
        }
        
        guard let url = buildSearchURL(query: query, apiKey: apiKey) else {
            completion(.failure(.invalidURL))
            return
        }
        
        networkManager.performRequest(url: url) { result in
            switch result {
            case .success(let data):
                do {
                    let cities = try JSONDecoder().decode([CitySearchResponse].self, from: data)
                    let searchResults = cities.map { CitySearchResult(from: $0) }
                    completion(.success(searchResults))
                } catch {
                    completion(.failure(.decodingError(error)))
                }
            case .failure(let networkError):
                completion(.failure(.networkError(networkError)))
            }
        }
    }
    
    private func buildSearchURL(query: String, apiKey: String) -> URL? {
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "limit", value: "10"),
            URLQueryItem(name: "appid", value: apiKey)
        ]
        return components?.url
    }
}
