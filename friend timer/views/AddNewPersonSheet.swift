//
//  AddNewPersonSheet.swift
//  friend timer
//
//  Created by Nicolas Fuchs on 02.11.25.
//

import SwiftUI

struct AddNewPersonSheet: View {
    @Bindable var newPerson: Person
    @Binding var isPresentingAddView: Bool
    var returnPersonTo: (Person, () -> Void) -> Void
    
    @Environment(ModelData.self) private var modelData
    
    var body: some View {
        NavigationView {
            AddNewPersonView(newPerson: newPerson)
                .navigationTitle($newPerson.name)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            isPresentingAddView = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            returnPersonTo(newPerson, modelData.saveToDisk)
                            modelData.friends.sort {
                                $0.lastContact < $1.lastContact
                            }
                            isPresentingAddView = false
                            removeNotification(Person: newPerson)       // if View is shown to edit an existing Person, remove its notification (if there is none, it gets ignored) and reschedule a new one to reflect the update that may have happend.
                            scheduleNotification(Person: newPerson)
                        }
                    }
                }
            
        }
    }
}

#Preview {
    AddNewPersonSheet(newPerson: Person(name: "Test Person",  priority: 1), isPresentingAddView: Binding.constant(true), returnPersonTo:  { _,_  in })
        .environment(ModelData())
}
