//
//  BackgroundTaskManager.swift
//  WeatherApp
//
//  Created by Phan Quyen on 13/08/2025.
//

import Foundation

class BackgroundTaskManager {
    static let shared = BackgroundTaskManager()
    
    private let dataQueue = DispatchQueue(label: "com.weatherapp.data", qos: .utility, attributes: .concurrent)
    private let networkQueue = DispatchQueue(label: "com.weatherapp.network", qos: .userInitiated)
    private let cacheQueue = DispatchQueue(label: "com.weatherapp.cache", qos: .background)
    
    private init() {}
    
    func performDataTask<T>(operation: @escaping () throws -> T, completion: @escaping (Result<T, Error>) -> Void) {
        dataQueue.async {
            do {
                let result = try operation()
                DispatchQueue.main.async {
                    completion(.success(result))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func performNetworkTask<T>(operation: @escaping (@escaping (Result<T, Error>) -> Void) -> Void, completion: @escaping (Result<T, Error>) -> Void) {
        networkQueue.async {
            operation { result in
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
    }
    
    func performCacheTask(operation: @escaping () -> Void) {
        cacheQueue.async {
            operation()
        }
    }
    
    func performConcurrentTasks<T>(tasks: [() throws -> T], completion: @escaping ([Result<T, Error>]) -> Void) {
        let group = DispatchGroup()
        var results: [Result<T, Error>] = Array(repeating: .failure(NSError(domain: "NotSet", code: 0)), count: tasks.count)
        let resultsQueue = DispatchQueue(label: "com.weatherapp.results")
        
        for (index, task) in tasks.enumerated() {
            group.enter()
            dataQueue.async {
                do {
                    let result = try task()
                    resultsQueue.async {
                        results[index] = .success(result)
                        group.leave()
                    }
                } catch {
                    resultsQueue.async {
                        results[index] = .failure(error)
                        group.leave()
                    }
                }
            }
        }
        
        group.notify(queue: .main) {
            completion(results)
        }
    }
    
    func performDelayedTask(delay: TimeInterval, task: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            task()
        }
    }
    
    func createRepeatingTimer(interval: TimeInterval, task: @escaping () -> Void) -> DispatchSourceTimer {
        let timer = DispatchSource.makeTimerSource(queue: .global(qos: .utility))
        timer.schedule(deadline: .now(), repeating: interval)
        timer.setEventHandler(handler: task)
        return timer
    }
    
    func startTimer(_ timer: DispatchSourceTimer) {
        timer.resume()
    }
    
    func stopTimer(_ timer: DispatchSourceTimer) {
        timer.cancel()
    }
}
