//
//  DataManager.swift
//  friend timer
//
//  Created by Nicolas Fuchs on 19.08.24.
//

import Foundation


class DataManager {
    private var modelData: ModelData

    init(modelData: ModelData) {
        self.modelData = modelData
    }

    func saveData() {
        // Implement your save logic here
    }
    
    func loadFromDisk() {
        modelData.loadFromDisk()
    }
}
