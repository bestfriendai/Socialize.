//
//  ResetTimerView.swift
//  friend timer
//
//  Created by Nicolas Fuchs on 24.11.25.
//

import SwiftUI

struct ResetTimerView: View {
    @Environment(ModelData.self) private var modelData: ModelData
    @Bindable var friend: Person

    
    func setLastContactToNow(id: UUID) {
        /*Takes in the id of a Person of which the lastContact property should be set to the Date "now"*/
        
        //Iterating over every Person in the friends array to find the one with the id where looking for, then setting its lastContact property to the Date "now"
        modelData.friends.first(where: { $0.id == id} )?.lastText = Date.now
        
        //sorting Persons from lastContact again, as this property could have changed
        modelData.friends.sort {
            $0.lastContact < $1.lastContact
        }
    }
    
    var body: some View {
        Button("No"){
            
        }
        Button("Yes"){
            setLastContactToNow(id: friend.id)
            scheduleNotification(Person: friend)
        }
    }
}

#Preview {
    ResetTimerView(friend: Person(name: "Test"))
}
