//
//  SampleData.swift
//  friend timer
//
//  Created by Nicolas Fuchs on 11.11.22.
//

import Foundation
import SwiftUI


var friendsSamples: [Person] = [Person(name: "Test1", lastContact: Date.now), Person(name: "Test 2", lastContact: Date.now.advanced(by: -5))]



func dataToModelData () {
    @Environment(ModelData.self) var modelData
    for friend in friendsSamples {
        modelData.friends.append(friend)
    }
}
