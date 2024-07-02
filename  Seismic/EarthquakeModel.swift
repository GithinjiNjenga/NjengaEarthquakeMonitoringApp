//
//  EarthquakeModel.swift
//  EarthquakeMonitoringApp
//
//  Created by Gracie on 28/06/2024.
//

import Foundation


struct Tremor: Codable {
    var type: String
    var metadata: Metadata
    var features: [Feature]
}

struct Metadata: Codable {
    var generated: Int
    var url: String
    var title: String
    var status: Int
    var api: String
    var count: Int
}

struct Feature: Codable {
    var type: String
    var properties: Property?
    var geometry: Geometry
    var id: String
}

struct Property: Codable {
    var mag: Double?
    var place: String
    var time: Int
    var magType: String
    var title: String
    var detail: String
}

struct Geometry: Codable {
    var type: String
    var coordinates: [Double]?
}


func decodeTremor(from jsonData: Data) {
    let decoder = JSONDecoder.customDecoder()
    
    do {
        let tremor = try decoder.decode(Tremor.self, from: jsonData)
        print("Decoded tremor data: \(tremor)")
    
    } catch {
        print("Error decoding JSON: \(error)")
    }
}
