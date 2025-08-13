//
//  WeatherService.swift
//  WeatherApp
//
//  Created by Phan Quyen on 13/08/2025.
//

import Foundation
import CoreLocation

class WeatherService {
    static let shared = WeatherService()
    
    private let baseURL = "https://api.openweathermap.org/data/2.5"
    private let apiKey = "cdf3aca7aeb52390af4bc0db457f5f60"
    private let networkManager = NetworkManager.shared
    
    private init() {}
    
    func getCurrentWeather(for city: String, completion: @escaping (Result<WeatherData, WeatherAPIError>) -> Void) {
        guard let url = buildWeatherURL(for: city) else {
            completion(.failure(.invalidURL))
            return
        }
        
        networkManager.performRequest(url: url) { result in
            self.handleWeatherResponse(result: result, completion: completion)
        }
    }
    
    func getCurrentWeather(latitude: Double, longitude: Double, completion: @escaping (Result<WeatherData, WeatherAPIError>) -> Void) {
        guard let url = buildWeatherURL(latitude: latitude, longitude: longitude) else {
            completion(.failure(.invalidURL))
            return
        }
        
        networkManager.performRequest(url: url) { result in
            self.handleWeatherResponse(result: result, completion: completion)
        }
    }
    
    func getForecast(for city: String, completion: @escaping (Result<([HourlyForecast], [DailyForecast]), WeatherAPIError>) -> Void) {
        guard let url = buildForecastURL(for: city) else {
            completion(.failure(.invalidURL))
            return
        }
        
        networkManager.performRequest(url: url) { result in
            self.handleForecastResponse(result: result, completion: completion)
        }
    }
    
    func getForecast(latitude: Double, longitude: Double, completion: @escaping (Result<([HourlyForecast], [DailyForecast]), WeatherAPIError>) -> Void) {
        guard let url = buildForecastURL(latitude: latitude, longitude: longitude) else {
            completion(.failure(.invalidURL))
            return
        }
        
        networkManager.performRequest(url: url) { result in
            self.handleForecastResponse(result: result, completion: completion)
        }
    }
    
    private func handleWeatherResponse(result: Result<Data, NetworkError>, completion: @escaping (Result<WeatherData, WeatherAPIError>) -> Void) {
        switch result {
        case .success(let data):
            do {
                let response = try JSONDecoder().decode(WeatherResponse.self, from: data)
                let weatherData = WeatherData(from: response)
                completion(.success(weatherData))
            } catch {
                completion(.failure(.decodingError(error)))
            }
        case .failure(let networkError):
            completion(.failure(.networkError(networkError)))
        }
    }
    
    private func handleForecastResponse(result: Result<Data, NetworkError>, completion: @escaping (Result<([HourlyForecast], [DailyForecast]), WeatherAPIError>) -> Void) {
        switch result {
        case .success(let data):
            do {
                let response = try JSONDecoder().decode(ForecastResponse.self, from: data)
                let hourlyForecasts = response.list.map { HourlyForecast(from: $0) }
                let dailyForecasts = processDailyForecast(from: response.list)
                completion(.success((hourlyForecasts, dailyForecasts)))
            } catch {
                completion(.failure(.decodingError(error)))
            }
        case .failure(let networkError):
            completion(.failure(.networkError(networkError)))
        }
    }
    
    private func buildWeatherURL(for city: String) -> URL? {
        var components = URLComponents(string: "\(baseURL)/weather")
        components?.queryItems = [
            URLQueryItem(name: "q", value: city),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: "metric")
        ]
        return components?.url
    }
    
    private func buildWeatherURL(latitude: Double, longitude: Double) -> URL? {
        var components = URLComponents(string: "\(baseURL)/weather")
        components?.queryItems = [
            URLQueryItem(name: "lat", value: String(latitude)),
            URLQueryItem(name: "lon", value: String(longitude)),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: "metric")
        ]
        return components?.url
    }
    
    private func buildForecastURL(for city: String) -> URL? {
        var components = URLComponents(string: "\(baseURL)/forecast")
        components?.queryItems = [
            URLQueryItem(name: "q", value: city),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: "metric")
        ]
        return components?.url
    }
    
    private func buildForecastURL(latitude: Double, longitude: Double) -> URL? {
        var components = URLComponents(string: "\(baseURL)/forecast")
        components?.queryItems = [
            URLQueryItem(name: "lat", value: String(latitude)),
            URLQueryItem(name: "lon", value: String(longitude)),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: "metric")
        ]
        return components?.url
    }
    
    private func processDailyForecast(from items: [ForecastItem]) -> [DailyForecast] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: items) { item in
            let date = Date(timeIntervalSince1970: TimeInterval(item.dt))
            return calendar.startOfDay(for: date)
        }
        
        return grouped.map { _, dayItems in
            DailyForecast(from: dayItems)
        }.sorted { $0.date < $1.date }
    }
}

enum WeatherAPIError: Error, LocalizedError {
    case invalidURL
    case noData
    case networkError(NetworkError)
    case decodingError(Error)
    case invalidAPIKey
    case cityNotFound
    case rateLimitExceeded
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .networkError(let networkError):
            return "Network error: \(networkError.localizedDescription)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .invalidAPIKey:
            return "Invalid API key"
        case .cityNotFound:
            return "City not found"
        case .rateLimitExceeded:
            return "API rate limit exceeded"
        }
    }
}
