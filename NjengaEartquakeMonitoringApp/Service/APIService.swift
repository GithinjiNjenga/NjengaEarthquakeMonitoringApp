//
//  Service.swift
//  EarthquakeMonitoringApp
//
//  Created by EMTECH MAC on 02/07/2024.

import RxSwift

import Foundation



class EarthquakeService {

    func fetchEarthquakes() -> Observable<[Tremor]> {

        
        return Observable.create { observer in

            let url = URL(string: "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson")!

            

            let task = URLSession.shared.dataTask(with: url) { data, response, error in

                if let error = error {

                    observer.onError(error)

                    return

                }

                

                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {

                    observer.onError(NSError(domain: "HTTP Error", code: 500, userInfo: nil))

                    return

                }

                

                guard let data = data else {

                    observer.onError(NSError(domain: "Data Error", code: 500, userInfo: nil))

                    return

                }

                

                do {

                    let earthquakeResponse = try JSONDecoder().decode(EarthquakeResponse.self, from: data)

                    

                    let earthquakes = earthquakeResponse.features.map { feature -> Earthquake in

                        return Earthquake(

                            id: feature.id,

                            magnitude: feature.properties.mag,

                            place: feature.properties.place,

                            time: Date(timeIntervalSince1970: feature.properties.time / 1000),

                            coordinates: (feature.geometry.coordinates[1], feature.geometry.coordinates[0])

                        )

                    }

                    

                    observer.onNext(earthquakes)

                    observer.onCompleted()

                    

                } catch {

                    observer.onError(error)

                }

            }

            

            task.resume()

            

            return Disposables.create {

                task.cancel()

            }

        }

    }

}
