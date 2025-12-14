//
//  data.swift
//  friend timer
//
//  Created by Nicolas Fuchs on 09.10.22.
//

#warning("TODO: Import Person´s through API from Contacts app")

import Foundation
import SwiftUI
import Combine
import UniformTypeIdentifiers

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
    
    init(id: UUID = UUID(), name: String = "", priority: Int = 7, lastText: Date = Date.now, lastJointActivity: Date = Date.now) {
        self.id = id
        self.name = name
        self.priority = priority
        self.lastText = lastText
        self.lastJointActivity = lastJointActivity
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case _name
        case _priority
        case _lastText
        case _lastJointActivity
    }
    
    // if a key can´t be decoded from the JSON file, don´t trow error but insert default value
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: ._name) ?? "Empty Name"
        priority = try container.decodeIfPresent(Int.self, forKey: ._priority) ?? 0
        lastText = try container.decodeIfPresent(Date.self, forKey: ._lastText) ?? Date.distantPast
        lastJointActivity = try container.decodeIfPresent(Date.self, forKey: ._lastJointActivity) ?? Date.distantPast
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Person(name: self.name, priority: self.priority, lastText: self.lastText, lastJointActivity: self.lastJointActivity)
        return copy
    }
    
    func update(newPerson: Person, callbackSaveToDisk: (() -> Void)) {
        self.name = newPerson.name
        self.priority = newPerson.priority
        self.lastText = newPerson.lastText
        self.lastJointActivity = newPerson.lastJointActivity
        callbackSaveToDisk()
    }
}

@Observable class ModelData: Codable, Transferable {
    var friends: [Person] = []
    { didSet {self.save(completion: {result in
        switch result {
        case .failure(let error):
            fatalError("Error while saving friends Array in ModelData to file "+error.localizedDescription)
        case .success(let savedPersonCount):
            print("Saved "+String(savedPersonCount)+" Entities to file")
        }
    })}
    }
        
    var error: AnyLocalizedError?
    
    init() {
        
    }
    
    required init(from decoder: any Decoder) {
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            friends = try container.decode([Person].self, forKey: ._friends)
        } catch {
            self.error = AnyLocalizedError(error)
        }
    }
    
    // make friends variable conform to codable
    enum CodingKeys: String, CodingKey {
        case _friends = "friends"
    }
    
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .json)
    }
    
    
    //function for generating URL for "friends.data"
    func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("friends.data")
    }
    
    func addNewPerson(person: Person, callbackSaveToDisk: (() -> Void)) -> Void {
        //add a new friend struct with a given name and given date; if no date is provided it uses the current date
        self.friends.append(person)
        self.friends.sort {
            $0.lastContact < $1.lastContact
        }
        callbackSaveToDisk()
    }
    
    
    func loadFromDisk() {
        do {
            let fileURL = try self.fileURL()

            load(fileURL: fileURL) { result in
                switch result {
                case .failure(let error):
                    self.error = AnyLocalizedError(error)
                    //fatalError("Error in loading modelData Array from file: "+error.localizedDescription)
                case .success(let personArrayFromFile):
                    DispatchQueue.main.async {
                        self.friends = personArrayFromFile
                    }
                    print("Loading completed: ")
                    for person in personArrayFromFile {
                        print(person.name)
                    }
                }
            }
        } catch {
            fatalError("Error in creating fileURL for modelData: "+error.localizedDescription)
        }
    }

    
    //function for loading data
    func load(fileURL: URL, completion: @escaping (Result<[Person], Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                    DispatchQueue.main.async {
                        completion(.failure(NSError(domain: "No file found", code: 0, userInfo: nil)))
                    }
                    return
                }
                let friendsArray = try JSONDecoder().decode([Person].self, from: file.availableData)
                DispatchQueue.main.async {
                    completion(.success(friendsArray))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    //function for saving data through a completion handler
    private func save(completion: @escaping (Result<Int, Error>)->Void){
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try JSONEncoder().encode(self.friends)
                let fileURL = try self.fileURL()
                try data.write(to: fileURL)
                DispatchQueue.main.async {
                    completion(.success(self.friends.count))
                }
            }catch{
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func saveToDisk() {
        self.save() { result in
            switch result {
            case .failure(let error):
                fatalError("Error while saving friends Array in ModelData to file "+error.localizedDescription)
            case .success(let savedPersonCount):
                print("Saved "+String(savedPersonCount)+" Entities to file")
            }
        }
    }
}

// Extend UTType for a custom type
extension UTType {
    static var personArray: UTType = UTType(exportedAs: "com.example.personArray")
}

// Extend Array to conform to Transferable when Element is Transferable
extension Array: @retroactive Transferable where Element: Transferable, Element: Codable {
    public static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .json)
    }
}

func formatDate(date:Date) -> String {
    let formatStyle: Date.RelativeFormatStyle
    if #available(iOS 18, *) {
        formatStyle = Date.RelativeFormatStyle(
            allowedFields: [.day],
            presentation: .named,
            unitsStyle: .spellOut,
            locale: Locale(identifier: "en_GB"),
            calendar: Calendar.current,
            capitalizationContext: .beginningOfSentence)
    } else {
        formatStyle = Date.RelativeFormatStyle(
            presentation: .named,
            unitsStyle: .spellOut,
            locale: Locale(identifier: "en_GB"),
            calendar: Calendar.current,
            capitalizationContext: .beginningOfSentence)
    }
    #warning("TODO: if relative time is under one minute display 'now' instead of seconds")
//    if abs(date.distance(to: Date.now)) > 86.400 {
        return formatStyle.format(date)
//    }else{
//        return "today"
//    }
}


struct AnyLocalizedError: LocalizedError {
    private let base: Error
    
    init(_ base: Error) {
        self.base = base
    }
    
    var errorDescription: String? {
        return base.localizedDescription
    }
}
