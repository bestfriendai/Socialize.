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
    
    @Bindable var newPerson: Person
    #warning("TODO: refresh Date every second or so -> should always display current date in selector/if not changed add current Date (Date.now) to newPerson")
    
    //var dateComponentsNow: DateComponents = Calendar.current.dateComponents([] , from: Date.now)
    
    func getDateComponentsWithDayOffset(dayOffset: Int) -> Date {
        var dateComponentsNow: DateComponents = Calendar.current.dateComponents([.year, .calendar, .month, .day, .hour, .minute] , from: Date.now)
        dateComponentsNow.setValue((dateComponentsNow.day ?? 0) + dayOffset, for: .day)
        return Calendar.current.date(from: dateComponentsNow) ?? Date.distantFuture
    }
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Name")) {
                    TextField("New Name", text: $newPerson.name)
                }
                Section(header: Text("Time of last Meeting")) {
                    DatePicker(selection: $newPerson.lastJointActivity, in: datesUntilNow ,label: {Text("Last met:") })
                        .datePickerStyle(.compact)
                    Picker("Days ago", selection: $newPerson.lastJointActivity ) {
                        Text("today").tag(getDateComponentsWithDayOffset(dayOffset: 0))
                        Text("yesterday").tag(getDateComponentsWithDayOffset(dayOffset: -1))
                        Text("2 days ago").tag(getDateComponentsWithDayOffset(dayOffset: -2))
                    }
                    .pickerStyle(.segmented)
                }
                
                
                Section(header:
                    Text("Time of last text")
                ) {
                    DatePicker("Last text:", selection: $newPerson.lastText, in: datesUntilNow)
                        .datePickerStyle(.compact)
                    Picker("Days ago", selection: $newPerson.lastText ) {
                        Text("today").tag(getDateComponentsWithDayOffset(dayOffset: 0))
                        Text("yesterday").tag(getDateComponentsWithDayOffset(dayOffset: -1))
                        Text("2 days ago").tag(getDateComponentsWithDayOffset(dayOffset: -2))
                    }
                    .pickerStyle(.segmented)
                }
                    
                //} label: {Text("Time of last text")}
                
                
                
                Section(header: Text("Priority")){
                    Picker(selection: $newPerson.priority, label: Text("Priority")) {
                        Text("High").tag(3)
                        Text("Medium").tag(7)
                        Text("Low").tag(14)
                    }
                    .pickerStyle(.segmented)
                    Stepper("Days until next follow-up: \(newPerson.priority)", value: $newPerson.priority, in: 1...31)
                }
                
                Section(header: Text("Next follow-up")){
//                    Text("\(newPerson.isOverdue ? "Overdue" : String(Int(newPerson.lastContact.addingTimeInterval(TimeInterval(newPerson.priority*86400)).timeIntervalSinceNow.rounded(.up)/86400))) days away")
//                    Text("\(formatDate(date: newPerson.lastContact.addingTimeInterval(TimeInterval(newPerson.priority*86400)), yeah: 2))")
                    Text("\(newPerson.isOverdue ? "Overdue" : formatDate(date: Calendar.current.date(byAdding: .day, value: Int(newPerson.priority), to: newPerson.lastContact)!))")
                    Text("\(newPerson.lastContact.addingTimeInterval(TimeInterval(newPerson.priority*86400)).formatted(date: .complete, time: .shortened))")

                }
                    
            }
            
            
        }
    }
}

struct AddNewPersonView_Previews: PreviewProvider {
    static var previews: some View {
        AddNewPersonView(newPerson: Person(priority: 4))
    }
}
