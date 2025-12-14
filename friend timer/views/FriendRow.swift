//
//  views.swift
//  friend timer
//
//  Created by Nicolas Fuchs on 10.10.22.
//

import Foundation
import SwiftUI

struct FriendRow: View {
    @Bindable var friend: Person
    @State var showAlert: Bool = false
    @State var showSheet: Bool = false
    @State var showDeleteConfirmation: Bool = false

    @Environment(ModelData.self) private var modelData: ModelData

    @StateObject var lastContactTimer = UpdaterViewModel() //Updates View every 60 second

    
    func delete() {
        modelData.friends.removeAll(where: { $0.id == friend.id })
    }
    
    var body: some View {
        Button(action: {showSheet = true}){
            HStack{
                VStack(alignment: .leading) {
                    Text(friend.name)
                        .font(.headline)
                    Text(formatDate(date:friend.lastContact))
                        .font(.subheadline)
#warning("TODO: Live Update the date; (maybe: when SystemTime changes (a second went by) reload view)")
                }
                Spacer()
                if (friend.isOverdue) {
                    Image(systemName: "clock.badge.exclamationmark")
                        .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.2, opacity: 1.0))
                }
            }
        }
        .swipeActions(edge: .leading) {
            Button(action:{showSheet = true}) {
                Label("Edit", systemImage: "pencil.line")
                    .labelStyle(IconOnlyLabelStyle())
                    .tint(.orange)
            }
        }
        .swipeActions() {
            Button(action:{ showDeleteConfirmation = true } ) {
                Label("Delete", systemImage: "trash")
                    .labelStyle(IconOnlyLabelStyle())
            }
            .tint(.red)
        }
        .confirmationDialog(
            String("Delete \($friend.name.wrappedValue)'s entry?"),
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Yes", role: .destructive) {
                withAnimation {delete()}
            }
//            Button("Cancel", role: .cancel) {
//                showDeleteConfirmation = false
//            }
        }
        .accentColor(/*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/)
        .sheet(isPresented: $showSheet, onDismiss: {
            //Alert(title: Text("Discard changes?"), primaryButton: .default(Text("No")), secondaryButton: .destructive(Text("Yes"), action: {showSheet = false}))
        }) {
            AddNewPersonSheet(newPerson: friend.copy() as! Person, isPresentingAddView: $showSheet, returnPersonTo: friend.update)
        }
        .alert("Reset timer?", isPresented: $showAlert) {
            ResetTimerView(friend: friend)
        }

    }
}

struct FriendRow_Previews: PreviewProvider {
    static var previews: some View {
        FriendRow(friend: friendsSamples[0])
        //FriendRow(friend: Person(name: "Test1", lastContact: Date.now, priority: 0))
    }
}
