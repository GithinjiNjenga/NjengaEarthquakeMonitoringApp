//
//  AppDelegate.swift
//  NjengaEartquakeMonitoringApp
//
//  Created by Gracie on 18/06/2024.
//

import UIKit
import MapKit
import RxSwift
import RxCocoa

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
        tableView.showsVerticalScrollIndicator = true
        return tableView
    }()
    
    let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.backgroundColor = .systemBackground
        searchBar.placeholder = "Search"
        return searchBar
    }()
    let mapTypeSegmentedControl: UISegmentedControl = {
            let segmentedControl = UISegmentedControl(items: ["Standard", "Satellite", "Hybrid"])
            segmentedControl.selectedSegmentIndex = 0
            return segmentedControl
        }()
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = .systemGray
      
        setupViews()
        bindViewModel()
        
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(EarthquakeTableViewCell.self, forCellReuseIdentifier: "cell")
        
        viewModel.fetchEarthquakes.onNext(())
        mapTypeSegmentedControl.addTarget(self, action: #selector(mapTypeChanged), for: .valueChanged)
    }
    
    func setupViews() {
        
        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.bounds.height / 3.7),
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
    @objc func mapTypeChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            mapView.mapType = .standard
        case 1:
            mapView.mapType = .satellite
        case 2:
            mapView.mapType = .hybrid
        default:
            mapView.mapType = .standard
        }
    }
    
    private func bindViewModel() {
        viewModel.earthquakes
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.updateUI()
            })
            .disposed(by: disposeBag)
        
        searchBar.rx.text.orEmpty
            .bind(to: viewModel.searchText)
            .disposed(by: disposeBag)
    }
    
    private func updateUI() {
        tableView.reloadData()
        addAnnotations(to: mapView, with: viewModel.filteredTremors)
    }
    
    func addAnnotations(to mapView: MKMapView, with tremors: [Tremor]) {
        mapView.removeAnnotations(mapView.annotations)
        for tremor in tremors {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: tremor.coordinates.latitudes, longitude: tremor.coordinates.longitude)
            annotation.title = tremor.place
            mapView.addAnnotation(annotation)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredTremors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < viewModel.filteredTremors.count else {
            return UITableViewCell() // Return an empty cell in case of index out of range
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! EarthquakeTableViewCell
        let tremor = viewModel.filteredTremors[indexPath.row]
        cell.configure(with: tremor)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.row < viewModel.filteredTremors.count else { return }
        
        let tremor = viewModel.filteredTremors[indexPath.row]
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: tremor.coordinates.latitudes, longitude: tremor.coordinates.longitude), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        mapView.setRegion(region, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchText.onNext(searchText)
    }
}

class EarthquakeTableViewCell: UITableViewCell {
    let magnitudeLabel = UILabel()
    let locationLabel = UILabel()
    let detailLabel = UILabel()
    let coordinatesLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        let stackView = UIStackView(arrangedSubviews: [magnitudeLabel, locationLabel, detailLabel,coordinatesLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        self.backgroundColor = .systemBackground
        
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with tremor: Tremor) {
        magnitudeLabel.text = "Magnitude: \(tremor.Magnitude)"
        locationLabel.text = "Location: \(tremor.place)"
        detailLabel.text = "Details: \(tremor.time)"
        //coordinatesLabel.text = "Coordinates: \(tremor.coordinates)"
    }
}
