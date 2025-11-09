//
//  AddNewPersonView.swift
//  friend timer
//
//  Created by Nicolas Fuchs on 10.10.22.
//

import SwiftUI
import Combine




let datesUntilNow = ...Date.now

struct AddNewPersonView: View {
    
    @ObservedObject var newPerson: Person
    #warning("TODO: refresh Date every second or so -> should always display current date in selector/if not changed add current Date (Date.now) to newPerson")
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Name")) {
                    TextField("New Name", text: $newPerson.name)
                }
                Section(header: Text("Time of last Meeting")) {
                    DatePicker(selection: $newPerson.lastContact, in: datesUntilNow ,label: {Text("Date of last meeting:") })
                        .datePickerStyle(.graphical)
                }
                Section(header: Text("Priority")){
                    Picker(selection: $newPerson.priority, label: Text("Priority")) {
                        Text("Low").tag(0)
                        Text("Medium").tag(1)
                        Text("High").tag(2)
                    }
                    .pickerStyle(.segmented)
                }
                    
            }
            
            
        }
    }
}

struct AddNewPersonView_Previews: PreviewProvider {
    static var previews: some View {
        AddNewPersonView(newPerson: Person())
    }
}
