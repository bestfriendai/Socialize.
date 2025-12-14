//
//  FriendList.swift
//  friend timer
//
//  Created by Nicolas Fuchs on 07.12.25.
//

import SwiftUI

struct FriendList: View {
    @Environment(ModelData.self) private var modelData
    
    @State private var searchFieldText: String = ""
    @FocusState private var searchFieldIsFocused: Bool

    @Binding var isPresentingAddView: Bool
    @State private var importing = false
    @State private var lastAddedIdentifiers: Set<String> = []
//    @State private var filter: CaptionOrder = .defaultText

    
    var body: some View {
        List {
            ForEach(modelData.friends) { friend in
                
                if searchFieldText.isEmpty || friend.name.localizedCaseInsensitiveContains(searchFieldText) {
                    FriendRow(friend: friend)
                }
            }
        }
        .listStyle(.inset)
        .refreshable {
            modelData.loadFromDisk()
        }
        .toolbarTitleDisplayMode(.large)
            .navigationTitle("Socialize.")
            .searchable(text: $searchFieldText)
            .toolbar {
                ToolbarItemGroup() {
                    // Import Data
                    Button(action: {
                        importing = true
                    }){
                        Image(systemName: "square.and.arrow.down")
                    }
                    .fileImporter(
                        isPresented: $importing,
                        allowedContentTypes: [.json]
                    ) { result in
                        switch result {
                        case .success(let importFileURL):
                            if importFileURL.startAccessingSecurityScopedResource() {
                                modelData.load(fileURL: importFileURL) { result in
                                    importFileURL.stopAccessingSecurityScopedResource()

                                    switch result {
                                    case .failure(let error):
                                        modelData.error = AnyLocalizedError(error)
                                    case .success(let personArrayFromFile):
                                        print(personArrayFromFile)
                                        DispatchQueue.main.async {
                                            modelData.friends = personArrayFromFile
                                        }
                                        print("Loading completed: ")
                                        for person in personArrayFromFile {
                                            print(person.name)
                                        }
                                    }
                                }
                            } else {
                                modelData.error = AnyLocalizedError(NSError(domain: "Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to obtain access to the security-scoped resource."]))
                            }

                        case .failure(let error):
                            modelData.error = AnyLocalizedError(error)
                        }
                    }

                    
                    // Export Data
                    ShareLink(item: modelData.friends, preview: SharePreview("Backup Data"))
                }
                if #available(iOS 26.0, *) {
                    DefaultToolbarItem(kind: .search, placement: .bottomBar)
                }
                ToolbarItemGroup(placement: .bottomBar ) {
                    //EditButton()
                    //TextField("Search", text: $searchFieldText)
                    //    .focused($searchFieldIsFocused)
                    Spacer()
//                  Add new Friend to List
                    Button(action: {
                        isPresentingAddView = true
                    }){
                        Image(systemName: "plus")
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
    }
    
    
}

#Preview {
    FriendList(isPresentingAddView: .constant(true))
        .environment(ModelData())
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

