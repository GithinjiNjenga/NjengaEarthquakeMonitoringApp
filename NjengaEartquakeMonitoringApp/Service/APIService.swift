//
//  Service.swift
//  EarthquakeMonitoringApp
//
//  Created by EMTECH MAC on 02/07/2024.
//

import Foundation
import RxSwift

class EarthquakeService {
    
    // Function to fetch earthquake data from a earthquake remote API
    func fetchEarthquakes(searchQuery: String? = nil) -> Observable<[Tremor]> {
        
        return Observable.create { observer in
            
            let url = URL(string: "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson")!
            
            // Create a data task to fetch data from the URL
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                
                // Handle any network errors
                if let error = error {
                    observer.onError(error)
                    return
                }
                
                // Check if the HTTP response status code is within the success range
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    observer.onError(NSError(domain: "HTTP Error", code: 500, userInfo: nil))
                    return
                }
                
                // Ensure there is data returned from the server
                guard let data = data else {
                    observer.onError(NSError(domain: "Data Error", code: 500, userInfo: nil))
                    return
                }
                
                // Parse JSON data into earthquake response model
                do {
                    let earthquakeResponse = try JSONDecoder().decode(EarthquakeResponse.self, from: data)
                    
                    // Transform earthquake response into Tremor objects
                    var earthquakes = earthquakeResponse.features.map { feature -> Tremor in
                        return Tremor(
                            id: feature.id,
                            Magnitude: feature.properties.mag,
                            place: feature.properties.place,
                            time: Date(timeIntervalSince1970: feature.properties.time / 1000),
                            coordinates: (feature.geometry.coordinates[1], feature.geometry.coordinates[0])
                        )
                    }
                    if let query = searchQuery, !query.isEmpty {
                        earthquakes = earthquakes.filter { tremor in
                            return tremor.place.lowercased().contains(query.lowercased())
                        }
                    }
                    // Send earthquakes to observer
                    observer.onNext(earthquakes)
                    observer.onCompleted()
                    
                } catch {
                    observer.onError(error)
                }
            }
            
            // Start the network request
            task.resume()
            
            // Return a disposable to clean up resources when observer is disposed
            return Disposables.create {
                task.cancel()
            }
        }
    }
}
