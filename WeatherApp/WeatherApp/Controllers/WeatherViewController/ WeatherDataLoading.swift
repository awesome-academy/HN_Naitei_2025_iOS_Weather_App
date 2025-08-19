//
//   WeatherDataLoading.swift
//  WeatherApp
//
//  Created by Phan Quyen on 19/08/2025.
//

import UIKit

extension WeatherViewController {
    
    func loadSampleData() {
        let allCities = [
            WeatherDisplayData(cityName: "Montreal, Canada", temperature: "19°", description: "", high: "", low: "", icon: ""),
            WeatherDisplayData(cityName: "Toronto, Canada", temperature: "20°", description: "", high: "", low: "", icon: ""),
            WeatherDisplayData(cityName: "Tokyo, Japan", temperature: "13°", description: "", high: "", low: "", icon: ""),
            WeatherDisplayData(cityName: "New York, USA", temperature: "22°", description: "", high: "", low: "", icon: ""),
            WeatherDisplayData(cityName: "London, UK", temperature: "15°", description: "", high: "", low: "", icon: ""),
            WeatherDisplayData(cityName: "Paris, France", temperature: "18°", description: "", high: "", low: "", icon: "")
        ]
        
        weatherDataList = Array(allCities.prefix(itemsPerPage))
        weatherTableView.reloadData()
    }
    
    func loadMoreDataIfNeeded() {
        guard !isLoadingMore && hasMoreData else { return }
        
        isLoadingMore = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.loadNextBatch()
        }
    }
    
    func loadNextBatch() {
        let moreCities = [
            WeatherDisplayData(cityName: "Amsterdam, Netherlands", temperature: "17°", description: "", high: "", low: "", icon: ""),
            WeatherDisplayData(cityName: "Vienna, Austria", temperature: "19°", description: "", high: "", low: "", icon: ""),
            WeatherDisplayData(cityName: "Prague, Czech Republic", temperature: "21°", description: "", high: "", low: "", icon: "")
        ]
        
        if currentPage < 4 {
            let startIndex = weatherDataList.count
            weatherDataList.append(contentsOf: moreCities)
            
            let indexPaths = (startIndex..<weatherDataList.count).map {
                IndexPath(row: $0, section: 0)
            }
            
            weatherTableView.insertRows(at: indexPaths, with: .fade)
            currentPage += 1
        } else {
            hasMoreData = false
        }
        
        isLoadingMore = false
    }
}
