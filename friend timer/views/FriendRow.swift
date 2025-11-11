//
//  views.swift
//  friend timer
//
//  Created by Nicolas Fuchs on 10.10.22.
//

import Foundation
import SwiftUI

struct FriendRow: View {
    @State var friend: Person
    @State var showAlert: Bool = false
    @State var showSheet: Bool = false

    @Environment(ModelData.self) private var modelData: ModelData

    @StateObject var lastContactTimer = UpdaterViewModel() //Updates View every 60 second
    
    func setLastContactToNow(id: UUID) {
        /*Takes in the id of a Person of which the lastContact property should be set to the Date "now"*/
        
        //Iterating over every Person in the friends array to find the one with the id where looking for, then setting its lastContact property to the Date "now"
        modelData.friends.first(where: { $0.id == id} )?.lastContact = Date.now
        
        //sorting Persons from lastContact again, as this property could have changed
        modelData.friends.sort {
            $0.lastContact < $1.lastContact
        }
    
    }
    
    func updatePerson(person: Person) -> Void {
        friend.name = person.name
        friend.lastContact = person.lastContact
        friend.priority = person.priority
        modelData.saveToDisk()
    }
    
    func delete() {
        modelData.friends.removeAll(where: { $0.id == friend.id })
    }
    
    var body: some View {
        Button(action: {showAlert = true}){
            HStack{
                VStack(alignment: .leading) {
                    Text(friend.name)
                        .font(.headline)
                    Text(formatDate(date:friend.lastContact))
                        .font(.subheadline)
#warning("TODO: Live Update the date; (maybe: when SystemTime changes (a second went by) reload view)")
                }
                Spacer()
                if (DateInterval(start: friend.lastContact, end: Date.now) > DateInterval(start: friend.lastContact, duration: 604800)) {
                    Image(systemName: "clock.badge.exclamationmark")
                        .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.2, opacity: 1.0))
                }
            }
        }
        .swipeActions() {
            Button(action:{showSheet = true}) {
                Label("Edit", systemImage: "pencil.line")
                    .labelStyle(IconOnlyLabelStyle())
                    .tint(.orange)
            }
            Button(role: .destructive, action:{delete()}) {
                Label("Delete", systemImage: "trash")
                    .labelStyle(IconOnlyLabelStyle())
                
            }
        }
        .accentColor(/*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/)
        .sheet(isPresented: $showSheet, onDismiss: {
            //Alert(title: Text("Discard changes?"), primaryButton: .default(Text("No")), secondaryButton: .destructive(Text("Yes"), action: {showSheet = false}))
        }) {
            AddNewPersonSheet(newPerson: friend.copy() as! Person, isPresentingAddView: $showSheet, returnPersonTo: updatePerson)
        }
        .alert("Reset timer?", isPresented: $showAlert) {
            Button("No"){
                
            }
            Button("Yes"){
                setLastContactToNow(id: friend.id)
                scheduleNotification(Person: friend)
            }
        }

    }
}

struct FriendRow_Previews: PreviewProvider {
    static var previews: some View {
        FriendRow(friend: friendsSamples[0])
        //FriendRow(friend: Person(name: "Test1", lastContact: Date.now, priority: 0))
    }
}
