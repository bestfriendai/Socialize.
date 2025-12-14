//
//  NotificationHandler.swift
//  friend timer
//
//  Created by Nicolas Fuchs on 23.10.22.
//

import Foundation
import UserNotifications

func addNotification(title:String, body:String, timeInterval:Double, personUUID: UUID?){
    //Create Content of notification
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    
    //create trigger
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
    
    //Create Notification request
    let uuidString = personUUID?.uuidString ?? UUID().uuidString
    let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
    
    //Schedule request with the system
    let notificationCenter = UNUserNotificationCenter.current()
    notificationCenter.add(request)
}

func removeNotification(Person: Person){
    let center = UNUserNotificationCenter.current()
    let uuidString = Person.id.uuidString
    center.removePendingNotificationRequests(withIdentifiers: [uuidString])
}
    
func configureNotificationTime(Person: Person) -> Double{
    //takes in priority of a newPerson and returns a double time NotificationInterval
    
    var notificationTimeInterval: Double
//    switch Person.priority {
//    case 0: notificationTimeInterval = 302400
//    case 1: notificationTimeInterval = 604800
//    case 2: notificationTimeInterval = 907200
//    default:
//        notificationTimeInterval = 20
//    }
    notificationTimeInterval = Double(Person.priority * 24 * 60 * 60)
        
    return notificationTimeInterval
}

func scheduleNotification(Person: Person) {
    //Requesting notification permission
    let center = UNUserNotificationCenter.current()
    center.requestAuthorization(options: [.alert, .badge, .sound]) {granted, error in
        if let error = error {
            print(error.localizedDescription)
        }
    }
    
    //getting notification permissions and settings
    center.getNotificationSettings { settings in
        guard settings.authorizationStatus == .authorized else {
            return
        }
        let notificationTimeInterval = configureNotificationTime(Person: Person)
        //Notification scheduling
        addNotification(title: Person.name, body: "Go text \(Person.name), it´s been \(Int(notificationTimeInterval/60/60/24)) days", timeInterval: notificationTimeInterval, personUUID: Person.id)
    }
}
