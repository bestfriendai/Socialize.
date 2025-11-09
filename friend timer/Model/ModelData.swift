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

class Person: Identifiable, Codable, ObservableObject, Transferable, NSCopying {
    
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .json)
    }
    
    let id: UUID
    var name: String
    var lastContact: Date
    var priority: Int
    
    init(id: UUID = UUID(), name: String = "", lastContact: Date = Date.now, priority: Int = 0) {
        self.id = id
        self.name = name
        self.lastContact = lastContact
        self.priority = priority
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Person(name: self.name, lastContact: self.lastContact, priority: self.priority)
        return copy
    }
    
    func clear() {
        self.name = ""
        self.lastContact = Date.now
        self.priority = 0
    }
}

@Observable final class ModelData: ObservableObject, Codable, Transferable {
    var friends: [Person] = []
    
    // make @Published variable conform to codable
    enum CodingKeys: String, CodingKey {
        case _friends = "friends"
    }
    
    /* 
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        friends = try container.decode([Person].self, forKey: .friends)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(friends, forKey: .friends)
    }
    */
    
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .json)
    }
    
    
    //function for generating URL for "friends.data"
    static func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("friends.data")
    }
    
    
    static func loadFromDisk(completion: @escaping (Result<[Person], Error>)->Void) {
        do {
            let fileURL = try fileURL()

            load(fileURL: fileURL) { result in
                switch result {
                case .failure(let error):
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                case .success(let personArrayFromFile):
                    DispatchQueue.main.async {
                        completion(.success(personArrayFromFile))
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        }
    }
    
    
    //function for loading data
    static func load(fileURL: URL, completion: @escaping (Result<[Person], Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                    DispatchQueue.main.async {
                        completion(.success([]))
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
    static func save(friends: [Person], completion: @escaping (Result<Int, Error>)->Void){
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try JSONEncoder().encode(friends)
                let fileURL = try fileURL()
                try data.write(to: fileURL)
                DispatchQueue.main.async {
                    completion(.success(friends.count))
                }
            }catch{
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
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
    let formatStyle = Date.RelativeFormatStyle(
                presentation: .named,
                unitsStyle: .spellOut,
                locale: Locale(identifier: "en_GB"),
                calendar: Calendar.current,
                capitalizationContext: .beginningOfSentence)
    #warning("TODO: if relative time is under one minute display 'now' instead of seconds")
    if date.distance(to: Date.now) > 86.400 {
        return formatStyle.format(date)
    }else{
        return "today"
    }
}

