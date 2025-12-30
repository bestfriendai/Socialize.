/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
An observable class that manages reading data from the contact store.
*/

import Contacts
import OSLog

@Observable
final class ContactStoreManager {
    /// Contains fetched contacts when the app receives a limited- or full-access authorization status.
    var contacts2: [Contact]
    var contacts: [CNContact]
    
    /// Contains the Contacts authorization status for the app.
    var authorizationStatus: CNAuthorizationStatus
    
    private let logger = Logger(subsystem: "ContactsAccess", category: "ContactStoreManager")
    private let store: CNContactStore
    private let keysToFetch: [any CNKeyDescriptor]
    
    init() {
        self.contacts = []
        self.contacts2 = []
        self.store = CNContactStore()
        self.authorizationStatus = .notDetermined
        self.keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactImageDataKey as any CNKeyDescriptor,
            CNContactImageDataAvailableKey as any CNKeyDescriptor,
            CNContactThumbnailImageDataKey as any CNKeyDescriptor,
            CNContactBirthdayKey as any CNKeyDescriptor
        ]
    }
    
    /// Fetches the Contacts authorization status of the app.
    func fetchAuthorizationStatus() {
        authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
    }
    
    /// Prompts the person for access to Contacts if the authorization status of the app can't be determined.
    func requestAcess() async {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        guard status == .notDetermined else { return }
        
        do {
            try await store.requestAccess(for: .contacts)
            
            // Update the authorization status of the app.
            fetchAuthorizationStatus()
        } catch {
            fetchAuthorizationStatus()
            logger.error("Requesting Contacts access failed: \(error)")
        }
    }
    
        /// Fetches all contacts authorized for the app and whose identifiers match a given list of identifiers.
    func fetchContacts(withIdentifiers identifiers: [String]) async {
        let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
        fetchRequest.sortOrder = .familyName
        fetchRequest.predicate = CNContact.predicateForContacts(withIdentifiers: identifiers)
        
        // mapped contacts
        let result2 = await executeFetchRequest2(fetchRequest)
        contacts2.append(contentsOf: result2)
        
        // CNContacts
        let result = await executeFetchRequest(fetchRequest)
        contacts.append(contentsOf: result)
    }
    
    /// Fetches all contacts authorized for the app.
    func fetchContacts() async {
        await requestAcess()
        let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
        fetchRequest.sortOrder = .familyName
        
        // mapped contacts
        let result2 = await executeFetchRequest2(fetchRequest)
        contacts2 = result2
        
        // CNContacts
        let result = await executeFetchRequest(fetchRequest)
        contacts = result
    }
    
    /// Executes the fetch request.
    nonisolated private func executeFetchRequest2(_ fetchRequest: CNContactFetchRequest) async -> [Contact] {
        let fetchingTask = Task {
            var result: [CNContact] = []
            
            do {
                try await store.enumerateContacts(with: fetchRequest) { contact, stop in
                    result.append(contact)
                }
            } catch {
                logger.error("Fetching contacts failed: \(error)")
            }
            
            let resultMapped = result.map({ $0.contact })
            return resultMapped
        }
        return await (fetchingTask.result).get()
    }
    
    /// Executes the fetch request.
    nonisolated private func executeFetchRequest(_ fetchRequest: CNContactFetchRequest) async -> [CNContact] {
        let fetchingTask = Task {
            var result: [CNContact] = []
            
            do {
                try await store.enumerateContacts(with: fetchRequest) { contact, stop in
                    result.append(contact)
                }
            } catch {
                logger.error("Fetching contacts failed: \(error)")
            }
            
            return result
        }
        return await (fetchingTask.result).get()
    }
}



extension CNContact {
    /// The formatted name of a contact.
    var formattedName: String {
        CNContactFormatter().string(from: self) ?? "Unknown contact"
    }
    
    /// The contact name's initials.
    var initials: String {
        String(self.givenName.prefix(1) + self.familyName.prefix(1))
    }
    
//    var birthday: Date? {
//        
//    }
    
    var contact: Contact {
        Contact(id: self.id.uuidString,
                givenName: self.givenName,
                familyName: self.familyName,
                fullName: self.formattedName,
                initials: self.initials,
                thumbNail: self.thumbnailImageData)
    }
    
    var person: Person {
        Person(id: self.id,
               name: self.formattedName,
               initialNotes: (self.birthday != nil) ? [Note(title: "Birthday", content: "", date: (self.birthday?.date)!, type: noteTypeEnum.date)] : []
        
        )
    }
}
