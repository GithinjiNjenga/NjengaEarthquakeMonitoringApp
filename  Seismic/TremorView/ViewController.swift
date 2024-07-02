//
//  AppDelegate.swift
//  NjengaEartquakeMonitoringApp
//
//  Created by Gracie on 18/06/2024.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    let viewModel = EarthquakeViewModel()
    
    let mapView: MKMapView = {
        let map = MKMapView()
        map.overrideUserInterfaceStyle = .dark
        return map
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .none
        tableView.largeContentTitle = "Data"

        return tableView
    }()
    
    let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.backgroundColor = .white
        searchBar.placeholder = "Search"
        return searchBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        setupViews()
        bindViewModel()
        viewModel.fetchEarthquakeData()
        
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(EarthquakeTableViewCell.self, forCellReuseIdentifier: "cell")
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
            searchBar.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: mapView.topAnchor)
        ])
    }
    
    private func bindViewModel() {
        viewModel.updateUI = { [weak self] in
            guard let self = self else { return }
            self.updateUI()
        }
    }
    
    private func updateUI() {
        tableView.reloadData()
        addAnnotations(to: mapView, with: viewModel.filteredTremors)
    }
    
    func addAnnotations(to mapView: MKMapView, with tremors: [Feature]) {
        mapView.removeAnnotations(mapView.annotations)
        for tremor in tremors {
            guard let coordinates = tremor.geometry.coordinates, coordinates.count >= 2 else { continue }
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: coordinates[1], longitude: coordinates[0])
            annotation.title = tremor.properties?.place
            mapView.addAnnotation(annotation)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredTremors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! EarthquakeTableViewCell
        let tremor = viewModel.filteredTremors[indexPath.row]
        cell.configure(with: tremor)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let tremor = viewModel.filteredTremors[indexPath.row]
        guard let coordinates = tremor.geometry.coordinates, coordinates.count >= 2 else { return }
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: coordinates[1], longitude: coordinates[0]), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        mapView.setRegion(region, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.filterTremors(with: searchText)
    }
}

class EarthquakeTableViewCell: UITableViewCell {
    @IBOutlet weak var magnitudeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    func configure(with tremor: Feature) {
        guard let magnitude = tremor.properties?.mag,
              let place = tremor.properties?.place else { return }
        magnitudeLabel.text = "Magnitude: \(magnitude)"
        locationLabel.text = "Location: \(place)"
        detailLabel.text = "Details: \(tremor.properties?.detail ?? "ok")"
    }
}
