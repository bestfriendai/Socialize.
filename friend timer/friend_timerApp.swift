//
//  friend_timerApp.swift
//  friend timer
//
//  Created by Nicolas Fuchs on 09.10.22.
//

import SwiftUI

@main
struct friend_timerApp: App {
    @State var modelData = ModelData()
       
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(modelData)
                .onAppear(perform: {
                    modelData.loadFromDisk()
                })
                .environment(modelData)
        }
    }
}
