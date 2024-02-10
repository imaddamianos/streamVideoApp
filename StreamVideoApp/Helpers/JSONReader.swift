//
//  JSONReader.swift
//  StreamVideoApp
//
//  Created by iMad on 10/02/2024.
//

import Foundation

class APICalls {
    static let shared = APICalls() // Singleton instance
    
    func readVideoModelsFromJSONFile() -> [MediaContent]? {
        guard let fileURL = Bundle.main.url(forResource: "media_content", withExtension: "json") else {
            print("JSON file not found.")
            return nil
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let videoModels = try decoder.decode([MediaContent].self, from: data)
            return videoModels
        } catch {
            print("Error decoding JSON: \(error.localizedDescription)")
            return nil
        }
    }
}



