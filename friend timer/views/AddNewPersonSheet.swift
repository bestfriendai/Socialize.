//
//  AddNewPersonSheet.swift
//  friend timer
//
//  Created by Nicolas Fuchs on 02.11.25.
//

import SwiftUI

struct AddNewPersonSheet: View {
    @ObservedObject var newPerson: Person
    @Binding var isPresentingAddView: Bool
    var function: (_ person: Person) -> Void
    
    @Environment(ModelData.self) private var modelData
    
    func saveToDisk() {
        ModelData.save(friends: modelData.friends) { result in
            switch result {
            case .failure(let error):
                fatalError("Error while saving friends Array in ModelData to file "+error.localizedDescription)
            case .success(let savedPersonCount):
                print("Saved "+String(savedPersonCount)+" Entities to file")
            }
        }
    }
    
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
                            function(newPerson)

                            isPresentingAddView = false
                            
                            scheduleNotification(Person: newPerson)

                            newPerson.clear()   //Gibt das Modell newPerson frei
                            
                            saveToDisk()
                        }
                    }
                }
        }
    }
}

#Preview {
    AddNewPersonSheet(newPerson: Person(name: "Test Person", lastContact: Date(), priority: 1), isPresentingAddView: Binding.constant(true), function:  { _ in })
}
