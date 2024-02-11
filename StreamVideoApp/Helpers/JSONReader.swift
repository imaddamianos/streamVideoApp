//
//  JSONReader.swift
//  StreamVideoApp
//
//  Created by iMad on 10/02/2024.
//

import Foundation

class APICalls {
    static let shared = APICalls() // Singleton instance
    
    
    func readHorizontalVideoModelsFromJSONFile() -> [MediaContent]? {
        guard let fileURL = Bundle.main.url(forResource: "horizontal_media_content", withExtension: "json") else {
            print("Horizontal JSON file not found.")
            return nil
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let videoModels = try decoder.decode([MediaContent].self, from: data)
            return videoModels
        } catch {
            print("Error decoding horizontal JSON: \(error.localizedDescription)")
            return nil
        }
    }
    
    func readVerticalVideoModelsFromJSONFile() -> [MediaContent]? {
        guard let fileURL = Bundle.main.url(forResource: "vertical_media_content", withExtension: "json") else {
            print("Vertical JSON file not found.")
            return nil
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let videoModels = try decoder.decode([MediaContent].self, from: data)
            return videoModels
        } catch {
            print("Error decoding vertical JSON: \(error.localizedDescription)")
            return nil
        }
    }
}




