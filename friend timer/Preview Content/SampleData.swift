//
//  SampleData.swift
//  friend timer
//
//  Created by Nicolas Fuchs on 11.11.22.
//

import Foundation
import SwiftUI
import Contacts

struct SampleData: PreviewModifier {
//    static let friendsSamples: [Person] = [Person(name: "Test1", lastText: Date.now), Person(name: "Test 2", lastText: Date.now.advanced(by: -5))]
    
    
    static func makeSharedContext() async throws -> ModelData {
        let modelData = ModelData()
//        for friend in Self.friendsSamples {
//            modelData.friends.append(friend)
//        }
        modelData.friends = [Person(name: "Test1", lastText: Date.now), Person(name: "Test 2", lastText: Date.now.advanced(by: -5))]
        //modelData.contactStoreManager.contacts = [CNContact(), CNContact()]
        return modelData
    }


    func body(content: Content, context: ModelData) -> some View {
        // Inject the object into the view to preview.
        content
            .environment(context)
    }
}
