//
//  TremorViewModel.swift
//  EarthquakeMonitoringApp
//
//  Created by EMTECH MAC on 02/07/2024.
//

import Foundation
import RxSwift
import RxCocoa

class EarthquakeViewModel {

    private let earthquakeService: EarthquakeService
    private let disposeBag = DisposeBag()

    
    let fetchEarthquakes = PublishSubject<Void>()
    let searchText = PublishSubject<String>()

    // Outputs
    let earthquakes = PublishSubject<[Tremor]>()
    private(set) var filteredTremors = [Tremor]()

    private var allTremors = [Tremor]()

    init(earthquakeService: EarthquakeService = EarthquakeService()) {
        self.earthquakeService = earthquakeService

        fetchEarthquakes
            .flatMapLatest { _ in
                earthquakeService.fetchEarthquakes()
                    .catch { error in
                        print("Error fetching earthquakes: \(error.localizedDescription)")
                        return Observable.just([])
                    }
            }
            .subscribe(onNext: { [weak self] tremors in
                self?.allTremors = tremors
                self?.filterTremors(with: "")
                self?.earthquakes.onNext(tremors)
            })
            .disposed(by: disposeBag)

        searchText
            .subscribe(onNext: { [weak self] text in
                self?.filterTremors(with: text)
            })
            .disposed(by: disposeBag)
    }

    func filterTremors(with searchText: String) {
        if searchText.isEmpty {
            filteredTremors = allTremors
        } else {
            filteredTremors = allTremors.filter { $0.place.contains(searchText) }
        }
    }
}
