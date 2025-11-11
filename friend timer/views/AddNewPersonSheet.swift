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
    var returnPersonTo: (Person) -> Void
    
    @Environment(ModelData.self) private var modelData
    
    var body: some View {
        NavigationView {
            AddNewPersonView(newPerson: newPerson)
                .navigationTitle($newPerson.name)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            newPerson.clear()
                            isPresentingAddView = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            returnPersonTo(newPerson)

                            isPresentingAddView = false
                            scheduleNotification(Person: newPerson)
                        }
                    }
                }
        }
    }
}

#Preview {
    AddNewPersonSheet(newPerson: Person(name: "Test Person", lastContact: Date(), priority: 1), isPresentingAddView: Binding.constant(true), returnPersonTo:  { _ in })
}
