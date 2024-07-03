//
//  TremorViewModel.swift
//  EarthquakeMonitoringApp
//
//  Created by EMTECH MAC on 02/07/2024.
//

import Foundation
import CoreData


class EarthquakeViewModel {
    
    var tremors: [Feature] = [] {
        didSet {
            self.updateUI?()
        }
    }
    var filteredTremors: [Feature] = [] {
        didSet {
            self.updateUI?()
        }
    }
    
    var updateUI: (() -> Void)?
    
    private let coreDataService = CoreDataService.shared
    
    func fetchEarthquakeData() {
        let urlString = "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    print("Failed to fetch earthquake data: \(error)")
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    print("No data received")
                }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let tremorData = try decoder.decode(Tremor.self, from: data)
                DispatchQueue.main.async {
                    self.tremors = tremorData.features
                }
            } catch {
                DispatchQueue.main.async {
                    print("Failed to parse earthquake data: \(error)")
                }
            }
        }.resume()
    }
    
    func addLocation(name: String, country: String, longitude: Double, latitude: Double) {
        coreDataService.addLocation(name: name, country: country, longitude: longitude, latitude: latitude)
    }
    
    //    func fetchLocations() -> [FavouritesModel] {
    //        return coreDataService.fetchLocation()
    
    func filterTremors(with query: String) {
        if query.isEmpty {
            filteredTremors = tremors
        } else {
            filteredTremors = tremors.filter { $0.properties?.place.lowercased().contains(query.lowercased()) ?? false }
        }
    }
}
