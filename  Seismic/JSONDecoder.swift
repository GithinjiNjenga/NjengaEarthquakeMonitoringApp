//
//  JSONDecoder.swift
//  EarthquakeMonitoringApp
//
//  Created by EMTECH MAC on 02/07/2024.
//

import Foundation

extension JSONDecoder {
    static func customDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        
        // Customize data decoding to handle base64-encoded data
        decoder.dataDecodingStrategy = .base64
        
        // Customize key decoding to convert snake_case to camelCase
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        // Customize float decoding to handle non-standard float values
        decoder.nonConformingFloatDecodingStrategy = .convertFromString(positiveInfinity: "+Infinity", negativeInfinity: "-Infinity", nan: "NaN")
        
        return decoder
    }
}
