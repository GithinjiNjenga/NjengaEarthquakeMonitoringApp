//
//  Service.swift
//  EarthquakeMonitoringApp
//
//  Created by EMTECH MAC on 02/07/2024.
//

import Foundation
import CoreData

class CoreDataService {
    
    static let shared = CoreDataService()
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "EarthquakeMonitoringApp")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    func addLocation(name: String, country: String, longitude: Double, latitude: Double) {
        let context = persistentContainer.viewContext
        
        guard let entity = NSEntityDescription.entity(forEntityName: "FavouritesModel", in: context) else {
            print("Failed to create entity description for FavouritesModel")
            return
        }
        
        let location = NSManagedObject(entity: entity, insertInto: context)
        
        location.setValue(name, forKey: "name")
        location.setValue(longitude, forKey: "longitude")
        location.setValue(latitude, forKey: "latitude")
        location.setValue(country, forKey: "country")
        
        do {
            try context.save()
            print("Location saved successfully")
        } catch let error as NSError {
            print("Failed to save location. \(error), \(error.userInfo)")
        }
    }
    
//    func fetchLocation() -> [FavouritesModel] {
//        let context = persistentContainer.viewContext
//        
//        let fetchRequest = NSFetchRequest<FavouritesModel>(entityName: "FavouritesModel")
//        
//        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
//        fetchRequest.sortDescriptors = [sortDescriptor]
//        
//        do {
//            let locationList = try context.fetch(fetchRequest)
//            return locationList
//        } catch let error as NSError {
//            print("Failed to fetch Locations from Core Data. \(error), \(error.userInfo)")
//            return []
//        }
//    }
}
