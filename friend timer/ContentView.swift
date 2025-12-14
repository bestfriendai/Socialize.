//
//  ContentView.swift
//  friend timer
//
//  Created by Nicolas Fuchs on 09.10.22.
//

import SwiftUI

struct ContentView: View {
    
    @Environment(ModelData.self) private var modelData
    
    @State var newPerson: Person = Person()
    
    @State private var isPresentingAddView = false
    @State private var errorOccured = false
    @State private var details: Error?

    
    @Environment(\.scenePhase) private var scenePhase   //operational State of the app gets saved to scenePhase from @Environment Property
    
    
    func delete(at offsets: IndexSet) {
        modelData.friends.remove(atOffsets: offsets)
    }
    
    func addNewPerson(person: Person) -> Void {
        //add a new friend struct with a given name and given date; if no date is provided it uses the current date
        modelData.friends.append(person)
        modelData.friends.sort {
            $0.lastContact < $1.lastContact
        }
    }
    
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text("Shows the friend you visited last on top, go text them now!")
                    .foregroundColor(Color.gray)
                    .padding([.leading, .trailing], 20.0)
                
                FriendList(isPresentingAddView: $isPresentingAddView)
                .sheet(isPresented: $isPresentingAddView) {
                    AddNewPersonSheet(newPerson: Person(), isPresentingAddView: $isPresentingAddView, returnPersonTo: modelData.addNewPerson)
                }
            }
            .onChange(of: scenePhase) { phase in
                if phase == .inactive {
                    modelData.saveToDisk()
                }
            }
            .alert(isPresented: Binding(get: {modelData.error != nil}, set: { if !$0 {modelData.error = nil} } ),
                   error: modelData.error)
            {
                Button("Retry loading from disk"){
                    modelData.loadFromDisk()
                }
                Button("Clear all data", role: .destructive){
                    modelData.friends.removeAll()
                    modelData.saveToDisk()      // overwrites the old save file with the current, probably empty, state, because there was an error
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(ModelData())
    }
}
