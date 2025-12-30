//
//  ContactAutocompleteList.swift
//  friend timer
//
//  Created by Nicolas Fuchs on 27.12.25.
//

import SwiftUI
import Contacts

struct ContactAutocompleteList: View {
    @Environment(ModelData.self) private var modelData
    
    @Bindable var newPerson: Person
    
    @Binding var searchFieldText: String
    @FocusState private var searchFieldIsFocused: Bool
    @FocusState var nameTextFieldIsFocused: Bool
    
    @Binding var isPresentingAddView: Bool
    @State private var importing = false
    @State private var lastAddedIdentifiers: Set<String> = []

    
    var body: some View {
        List {
            ForEach(modelData.contactStoreManager.contacts) { contact in
                if contact.contact.fullName.localizedCaseInsensitiveContains(searchFieldText) && !(contact.formattedName == newPerson.name) && nameTextFieldIsFocused {
                    ContactRow(newPerson: newPerson, contact: contact, nameTextFieldIsFocused: _nameTextFieldIsFocused)
                }
            }
        }

    }
    
    
}


struct ContactRow: View {
    @Environment(ModelData.self) private var modelData
    
    @Bindable var newPerson: Person
    let contact: CNContact
    @FocusState var nameTextFieldIsFocused: Bool
    
    func fillContact() {
        newPerson.update(newPerson: contact.person, callbackSaveToDisk: modelData.saveToDisk)
    }
    
    var body: some View {
        HStack {
            Button(action: {
                fillContact()
                nameTextFieldIsFocused.toggle()
            }) {
                Text(contact.formattedName)
                    .font(.headline)
            }
        }
    }
}

private struct ContactAutocompleteList_PreviewWrapper: View {
    @State var searchText: String = "Test1"
    @State var isPresenting: Bool = true
    @FocusState var nameFocus: Bool

    var body: some View {
        ContactAutocompleteList(
            newPerson: Person(name: "Test1"),
            searchFieldText: $searchText,
            nameTextFieldIsFocused: _nameFocus,
            isPresentingAddView: $isPresenting
        )
        .onAppear {
            // Activate focus for preview to exercise autocomplete UI
            nameFocus = true
        }
    }
}

#Preview(traits: .modifier(SampleData())) {
    ContactAutocompleteList_PreviewWrapper()
}

//struct FriendList_Previews: PreviewProvider {
//    var modelData = ModelData()
//    modelData.friends.append(Person(name: "New Friend"))
//
//    static var previews: some View {
//        ContentView()
//            .environment(modelData)
//    }
//}

