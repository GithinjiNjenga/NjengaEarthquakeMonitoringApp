//
//  AppDelegate.swift
//  NjengaEartquakeMonitoringApp
//
//  Created by Gracie on 18/06/2024.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    let mapView: MKMapView = {
        let map = MKMapView()
        map.overrideUserInterfaceStyle = .dark
        return map
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .systemGreen
        tableView.separatorStyle = .none
        return tableView
    }()
    let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.backgroundColor = .white
        searchBar.placeholder = "Search"
        return searchBar
    }()
    
    let imageView = UIImageView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        fetchEarthquakeData()
//        addAnnotationsToMap()
    }
    
    func setupViews() {
        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.bounds.height / 3),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        
        view.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.topAnchor, constant:100),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // Then add the table view
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: mapView.topAnchor)
        ])
        
        // Additional setup for image view animation
        imageView.frame = view.bounds
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "launch image")
        imageView.alpha = 0
        view.addSubview(imageView)
        
        // Animation sequence
        UIView.animate(withDuration: 1.0, animations: {
            self.imageView.alpha = 1
        }) { (finished) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.fadeOutImage()
            }
        }
    }
    
    func fadeOutImage() {
        UIView.animate(withDuration: 1.0, animations: {
            self.imageView.alpha = 0
        }) { (finished) in
            self.imageView.removeFromSuperview()
            
            let nextViewController = NextViewController()
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }
    }
    
    
    private func fetchEarthquakeData() {
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
                    
                    self.updateUI(with: tremorData)
                    print("Successfully fetched earthquake data:")
                    print(tremorData)
                }
            } catch {
                DispatchQueue.main.async {
                    print("Failed to parse earthquake data: \(error)")
                    
                }
            }
        }.resume()
    }
    
    private func updateUI(with tremorData: Tremor) {
        
    }
//    private func addAnnotationsToMap() {
//        guard let earthquakes = earthquakeData?.features else { return }
//
//        for earthquake in earthquakes {
//            guard let geometry = earthquake.geometry,
//                  let coordinates = geometry.coordinates else { continue }
//
//            let magnitude = earthquake.properties?.magnitude ?? 0.0
//            let coordinate = CLLocationCoordinate2D(latitude: coordinates[1], longitude: coordinates[0])
//            let annotation = MKPointAnnotation()
//            annotation.coordinate = coordinate
//            annotation.title = "Magnitude: \(magnitude)"
//
//            mapView.addAnnotation(annotation)
//        }
//    }
//
}

extension ViewController: MKMapViewDelegate {
}




