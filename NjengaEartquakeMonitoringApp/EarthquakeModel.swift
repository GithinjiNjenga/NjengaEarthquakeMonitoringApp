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
    var updated: Int?
    var tz: Int?
    var url: String
    var detail: String
    var felt: Int?
    var cdi: Double?
    var mmi: Double?
    var alert: String?
    var status: String
    var tsunami: Int
    var sig: Int
    var net: String
    var code: String
    var ids: String
    var sources: String
    var types: String
    var nst: Int?
    var dmin: Double?
    var rms: Double
    var gap: Int?
    var magType: String
    var title: String

   
}

struct Geometry: Codable {
    var type: String
    var coordinates: [Double]
}
