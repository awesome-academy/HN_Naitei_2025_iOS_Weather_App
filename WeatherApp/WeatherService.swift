//
//  WeatherService.swift
//  WeatherApp
//
//  Created by Phan Quyen on 08/08/2025.
//

import Foundation

class WeatherService {
    static let shared = WeatherService()
    
    private let baseURL = "https://api.openweathermap.org/data/2.5"
    private let apiKey = "cdf3aca7aeb52390af4bc0db457f5f60"
    private let networkManager = NetworkManager.shared
    
    private init() {}
    
    func getCurrentWeather(latitude: Double, longitude: Double, completion: @escaping (Result<WeatherData, NetworkError>) -> Void) {
        guard let url = buildWeatherURL(lat: latitude, lon: longitude) else {
            completion(.failure(.invalidURL))
            return
        }
        
        networkManager.performRequest(url: url) { result in
            switch result {
            case .success(let data):
                do {
                    let response = try JSONDecoder().decode(WeatherResponse.self, from: data)
                    let weatherData = WeatherData(from: response)
                    completion(.success(weatherData))
                } catch {
                    completion(.failure(.decodingFailed))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getCurrentWeather(cityName: String, completion: @escaping (Result<WeatherData, NetworkError>) -> Void) {
        guard let url = buildWeatherURL(cityName: cityName) else {
            completion(.failure(.invalidURL))
            return
        }
        
        networkManager.performRequest(url: url) { result in
            switch result {
            case .success(let data):
                do {
                    let response = try JSONDecoder().decode(WeatherResponse.self, from: data)
                    let weatherData = WeatherData(from: response)
                    completion(.success(weatherData))
                } catch {
                    completion(.failure(.decodingFailed))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getForecast(latitude: Double, longitude: Double, completion: @escaping (Result<([HourlyForecast], [DailyForecast]), NetworkError>) -> Void) {
        guard let url = buildForecastURL(lat: latitude, lon: longitude) else {
            completion(.failure(.invalidURL))
            return
        }
        
        networkManager.performRequest(url: url) { result in
            switch result {
            case .success(let data):
                do {
                    let response = try JSONDecoder().decode(ForecastResponse.self, from: data)
                    let hourlyForecasts = response.list.map { HourlyForecast(from: $0) }
                    let dailyForecasts = self.processDailyForecast(from: response.list)
                    completion(.success((hourlyForecasts, dailyForecasts)))
                } catch {
                    completion(.failure(.decodingFailed))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getForecast(cityName: String, completion: @escaping (Result<([HourlyForecast], [DailyForecast]), NetworkError>) -> Void) {
        guard let url = buildForecastURL(cityName: cityName) else {
            completion(.failure(.invalidURL))
            return
        }
        
        networkManager.performRequest(url: url) { result in
            switch result {
            case .success(let data):
                do {
                    let response = try JSONDecoder().decode(ForecastResponse.self, from: data)
                    let hourlyForecasts = response.list.map { HourlyForecast(from: $0) }
                    let dailyForecasts = self.processDailyForecast(from: response.list)
                    completion(.success((hourlyForecasts, dailyForecasts)))
                } catch {
                    completion(.failure(.decodingFailed))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func buildWeatherURL(lat: Double, lon: Double) -> URL? {
        var components = URLComponents(string: "\(baseURL)/weather")
        components?.queryItems = [
            URLQueryItem(name: "lat", value: String(lat)),
            URLQueryItem(name: "lon", value: String(lon)),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: "metric")
        ]
        return components?.url
    }
    
    private func buildWeatherURL(cityName: String) -> URL? {
        var components = URLComponents(string: "\(baseURL)/weather")
        components?.queryItems = [
            URLQueryItem(name: "q", value: cityName),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: "metric")
        ]
        return components?.url
    }
    
    private func buildForecastURL(lat: Double, lon: Double) -> URL? {
        var components = URLComponents(string: "\(baseURL)/forecast")
        components?.queryItems = [
            URLQueryItem(name: "lat", value: String(lat)),
            URLQueryItem(name: "lon", value: String(lon)),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: "metric")
        ]
        return components?.url
    }
    
    private func buildForecastURL(cityName: String) -> URL? {
        var components = URLComponents(string: "\(baseURL)/forecast")
        components?.queryItems = [
            URLQueryItem(name: "q", value: cityName),
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

