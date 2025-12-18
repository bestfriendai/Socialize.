//
//  PersonInfoView.swift
//  friend timer
//
//  Created by Nicolas Fuchs on 17.12.25.
//

import SwiftUI


struct PersonInfoView: View {
    @Bindable var selectedPerson: Person
    @State var newSectionLabel: String = ""

    @State var isExpanded: Bool = true
    @State var newNoteCategory: noteTypeEnum = .text


    var body: some View {
        VStack() {
            List {
                ForEach($selectedPerson.notes) { $note in

//                    DisclosureGroup(note.title, isExpanded: $isExpanded) {
//                        TextField("", text: $note.content, axis: .vertical)
//                    }
//                    Section(isExpanded: $isExpanded) {
//                        TextField("", text: $note.content, axis: .vertical)
//                        
//                    } header: {
//                            TextField("", text: $note.title)
//                    }
                    oneNoteView(note: note)
                }
                
//                Section(header: Text("add new section")) {
//                    Button("Add Note", systemImage: "text.badge.plus") {
//                        selectedPerson.notes.append(Note(title: "New Note", content: "New Note Content"))
//                    }
//                    
//                    Button {
//                        selectedPerson.notes.append(Note(title: "New Note", content: "New Note Content"))
//                    } label: {
//                        HStack{
//                            Image(systemName: "text.badge.plus")
//                            TextField("", text: $newSectionLabel).frame(maxWidth: CGFloat((newSectionLabel.count*10)))
//                        }
//                    }
//                }
                
                Section() {
                    HStack{
                        Image(systemName: "text.badge.plus")
                        TextField("", text: $newSectionLabel, prompt: Text("Add new Section"))
                            .onSubmit {
                                selectedPerson.notes.append(Note(title: newSectionLabel, content: ""))
                                newSectionLabel = ""
                            }
                            .submitLabel(.send)

                        Spacer()
                        
                        Button("Add Note", systemImage: "plus.circle") {
                            selectedPerson.notes.append(Note(title: newSectionLabel, content: "", type: newNoteCategory))
                            newSectionLabel = ""
                        }
                        //.labelStyle(.iconOnly)
                        //.foregroundStyle(Color(.tintColor))
                        .buttonStyle(.borderedProminent)

                    }
                    Picker("Category:", selection: $newNoteCategory) {
                        Label("Text", systemImage: "text.page").tag(noteTypeEnum.text)
                        Label("Date", systemImage: "calendar").tag(noteTypeEnum.date)
                        Label("Number", systemImage: "numbers").tag(noteTypeEnum.int)
                    }
                    .pickerStyle(.palette)
                    
                }
            }
            .listStyle(.sidebar)
            
//            List(selectedPerson.notes) {
//                Text($0.content)
//            }
        }.animation(.default, value: selectedPerson.notes.count)
    }
}

struct oneNoteView: View {
    @Bindable var note: Note
    @State var isExpanded: Bool = true

    var body: some View {
        Section(isExpanded: $isExpanded,
            content: {
            switch note.type {
            case .date:
                DatePicker(note.title, selection: $note.date)
                    .datePickerStyle(.compact)
            case .text:
                TextField("", text: $note.content, prompt: Text("Time to enter something about \(note.title)"), axis: .vertical)
            case .int:
                HStack{
                    Text("\(note.title):")
                    TextField("Enter a value", value: $note.intValue, formatter: NumberFormatter())
                        .keyboardType(.decimalPad)
                    Stepper("", value: $note.intValue, in: 0...100)
                }
                
            }
            
            

                
            }, header: {
                TextField("", text: $note.title)
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
        )
    }
}


#Preview {
    PersonInfoView(selectedPerson: Person(name: "Test Person 1", initialNotes: [Note(title: "Test", content: "Test Content here is the test content"), Note(title: "Test2", content: "Test Content for Note 2 here is the test content"), Note(title: "Test Integer", content: "Test Content for Note 3 here is the test content", type: .int), Note(title: "Test Date", content: "Test Content for Note 4 here is the test content", type: .date)]))
}
