//
//  Person.swift
//  friend timer
//
//  Created by Nicolas Fuchs on 17.12.25.
//

import SwiftUI

#warning("TODO: Import Person´s through API from Contacts app")

@Observable class Person: Identifiable, Codable, Transferable, NSCopying {
    
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .json)
    }
    
    let id: UUID
    var name: String
    var lastContact: Date {
        max(self.lastText, self.lastJointActivity)
    }
    var lastText: Date
    var lastJointActivity: Date
    var priority: Int
    var isOverdue: Bool {
        return self.lastContact.timeIntervalSinceNow < TimeInterval(-(priority*24*60*60))
    }
    
    var notes: [Note]
    
    init(id: UUID = UUID(), name: String = "", priority: Int = 7, lastText: Date = Date.now, lastJointActivity: Date = Date.now, initialNotes: [Note] = []) {
        self.id = id
        self.name = name
        self.priority = priority
        self.lastText = lastText
        self.lastJointActivity = lastJointActivity
        self.notes = initialNotes
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case _name
        case _priority
        case _lastText
        case _lastJointActivity
        case _notes
    }
    
    // if a key can´t be decoded from the JSON file, don´t trow error but insert default value
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: ._name) ?? "Empty Name"
        priority = try container.decodeIfPresent(Int.self, forKey: ._priority) ?? 0
        lastText = try container.decodeIfPresent(Date.self, forKey: ._lastText) ?? Date.distantPast
        lastJointActivity = try container.decodeIfPresent(Date.self, forKey: ._lastJointActivity) ?? Date.distantPast
        notes = try container.decodeIfPresent([Note].self, forKey: ._notes) ?? []
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Person(name: self.name, priority: self.priority, lastText: self.lastText, lastJointActivity: self.lastJointActivity, initialNotes: self.notes)
        return copy
    }
    
    func update(newPerson: Person, callbackSaveToDisk: (() -> Void)) {
        self.name = newPerson.name
        self.priority = newPerson.priority
        self.lastText = newPerson.lastText
        self.lastJointActivity = newPerson.lastJointActivity
        self.notes = newPerson.notes
        callbackSaveToDisk()
    }
}


@Observable class Note: Identifiable, Codable {
    let id: UUID
    var title: String
    var content: String
    var date: Date
    var intValue: Int
    var type: noteTypeEnum
    
    init(title: String, content: String, type: noteTypeEnum = .text) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.date = Date()
        self.intValue = 0
        self.type = type
    }
}



enum noteTypeEnum: String, Codable {
    case date, text, int
}
