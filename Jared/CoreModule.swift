//
//  CoreModule.swift
//  Jared 3.0 - Swiftified
//
//  Created by Zeke Snider on 4/3/16.
//  Copyright © 2016 Zeke Snider. All rights reserved.
//

import Foundation
import Cocoa
import JaredFramework
import Contacts
import RealmSwift

public func NSLocalizedString(_ key: String) -> String {
    return NSLocalizedString(key, tableName: "CoreStrings", comment: "")
}

class CoreModule: RoutingModule {
    var description: String = NSLocalizedString("CoreDescription")
    var routes: [Route] = []
    let MAXIMUM_CONCURRENT_SENDS = 3
    var currentSends: [String: Int] = [:]
    let scheduleCheckInterval = 30.0 * 60.0
    
    let mystring = NSLocalizedString("hello", tableName: "CoreStrings", value: "", comment: "")
    
    required public init() {
        let appsupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("Jared").appendingPathComponent("CoreModule")
        let realmLocation = appsupport.appendingPathComponent("database.realm")
            
        try! FileManager.default.createDirectory(at: appsupport, withIntermediateDirectories: true, attributes: nil)
        
        let config = Realm.Configuration(
            fileURL: realmLocation.absoluteURL
        )
        Realm.Configuration.defaultConfiguration = config
        
        let ping = Route(name:"/ping", comparisons: [.startsWith: ["/ping"]], call: self.pingCall, description: NSLocalizedString("pingDescription"))
        
        let thankYou = Route(name:"Thank You", comparisons: [.startsWith: [NSLocalizedString("ThanksJaredCommand")]], call: self.thanksJared, description: NSLocalizedString("ThanksJaredResponse"))
        
        let version = Route(name: "/version", comparisons: [.startsWith: ["/version"]], call: self.getVersion, description: "Get the version of Jared running")
        
        let whoami = Route(name: "/whoami", comparisons: [.startsWith: ["/whoami"]], call: self.getWho, description: "Get your name")
        
        let send = Route(name: "/send", comparisons: [.startsWith: ["/send"]], call: self.sendRepeat, description: NSLocalizedString("sendDescription"),parameterSyntax: NSLocalizedString("sendSyntax"))
        
        let name = Route(name: "/name", comparisons: [.startsWith: ["/name"]], call: self.changeName, description: "Change what Jared calls you", parameterSyntax: "/name,[your preferred name]")
        
        let schedule = Route(name: "/schedule", comparisons: [.startsWith: ["/schedule"]], call: self.schedule, description: NSLocalizedString("scheduleDescription"), parameterSyntax: "/schedule")

        routes = [ping, thankYou, version, send, whoami, name, schedule]
        
        //Launch background thread that will check for scheduled messages to send
        let dispatchQueue = DispatchQueue(label: "Message Scheduling Background Thread", qos: .background)
        dispatchQueue.async(execute: self.scheduleThread)
    }
    
    
    func pingCall(incoming: Message) -> Void {
        Send(NSLocalizedString("PongResponse"), to: incoming.RespondTo())
    }
    
    func getWho(message: Message) -> Void {
        if message.sender.givenName != nil {
            Send("Your name is \(message.sender.givenName!).", to: message.RespondTo())
        }
        else {
            Send("I don't know your name.", to: message.RespondTo())
        }
    }
    
    func thanksJared(message: Message) -> Void {
        Send(NSLocalizedString("WelcomeResponse"), to: message.RespondTo())
    }
    
    func getVersion(message: Message) -> Void {
        Send(NSLocalizedString("versionResponse"), to: message.RespondTo())
    }
    
    var guessMin: Int? = 0
    
    func sendRepeat(message: Message) -> Void {
        guard let parameters = message.getTextParameters() else {
            return Send("Inappropriate input type.", to: message.RespondTo())
        }
        
        //Validating and parsing arguments
        guard let repeatNum: Int = Int(parameters[1]) else {
            return Send("Wrong argument. The first argument must be the number of message you wish to send", to: message.RespondTo())
        }
        
        guard let delay = Int(parameters[2]) else {
            return Send("Wrong argument. The second argument must be the delay of the messages you wish to send", to: message.RespondTo())
        }
        
        guard var textToSend = parameters[safe: 3] else {
            return Send("Wrong arguments. The third argument must be the message you wish to send.", to: message.RespondTo())
        }
        
        guard (currentSends[message.sender.handle] ?? 0) < MAXIMUM_CONCURRENT_SENDS else {
            return Send("You can only have \(MAXIMUM_CONCURRENT_SENDS) send operations going at once.", to: message.RespondTo())
        }
        
        if (currentSends[message.sender.handle] == nil)
        {
            currentSends[message.sender.handle] = 0
        }
        
        //Increment the concurrent send counter for this user
        currentSends[message.sender.handle] = currentSends[message.sender.handle]! + 1
        
        //If there are commas in the message, take the whole message
        if parameters.count > 4 {
            textToSend = parameters[3...(parameters.count - 1)].joined(separator: ",")
        }
        
        //Go through the repeat loop...
        for _ in 1...repeatNum {
            Send(textToSend, to: message.RespondTo())
            Thread.sleep(forTimeInterval: Double(delay))
        }
        
        //Decrement the concurrent send counter for this user
        currentSends[message.sender.handle] = (currentSends[message.sender.handle] ?? 0) - 1
        
    }
    
    func scheduleThread() {
        //Get all scheduled posts
        let realm  = try! Realm()
        let posts = realm.objects(SchedulePost.self)
        
        let nowDate = Date().timeIntervalSinceReferenceDate
        let lowerIntervalBound = nowDate - scheduleCheckInterval
        
        //Loop over all posts
        for post in posts {
            //Number of send intervals since lower bound
            let lowerTimeDiff = (lowerIntervalBound - post.startDate.timeIntervalSinceReferenceDate) / (intervalSeconds[post.sendIntervalTypeEnum]! * Double(post.sendIntervalNumber))
            
            //Number of send intervals since upper bound
            let upperTimeDiff = (nowDate - post.startDate.timeIntervalSinceReferenceDate) / (intervalSeconds[post.sendIntervalTypeEnum]! * Double(post.sendIntervalNumber))
            let roundedLower = floor(lowerTimeDiff)
            let roundedHigher = ceil(upperTimeDiff)
            
            //Check to see if we are within the re-send period for this scheduled message
            //values should converge on the number of send interval if we're supposed to send.
            if (roundedHigher - roundedLower == Double(post.sendIntervalNumber)) {

                //Check to make sure the last time we sent this scheduled message it was not within this send interval
                if (nowDate - post.lastSendDate.timeIntervalSinceReferenceDate) > (Double(post.sendIntervalNumber) * intervalSeconds[post.sendIntervalTypeEnum]!) {
                    //Send the message and write to the database with the new lastSendDate
//                    let sendRoom = Room(GUID: post.chatID, buddyName: "", buddyHandle: post.handle)
//                    Send(post.text, toRoom: sendRoom)
//                    try! realm.write {
//                        post.lastSendDate = Date()
//                    }
                }
            }
            //We've gone over when the last message for the schedule would have sent. We should delete it from the database
            else if Int(roundedLower) > post.sendNumberTimes {
                try! realm.write {
                    realm.delete(post)
                }
            }
        }
        
        //Wait for next iteration...
        Thread.sleep(forTimeInterval: Double(scheduleCheckInterval))
        scheduleThread()
    }
    
    func schedule(message: Message) {
        // /schedule,add,1,week,5,full Message
        // /schedule,delete,1
        // /schedule,list
        guard let parameters = message.getTextBody()?.components(separatedBy: ",") else {
            return Send("Inappropriate input type", to:message.RespondTo())
        }
        
        guard parameters.count > 1 else {
            return Send("More parameters required.", to: message.RespondTo())
        }
        
        let realm  = try! Realm()
        
        switch parameters[1] {
        case "add":
            guard parameters.count > 5 else {
                return Send("Incorrect number of parameters specified.", to: message.RespondTo())
            }
            
            guard let sendIntervalNumber = Int(parameters[2]) else {
                return Send("Send interval number must be an integer.", to: message.RespondTo())
            }
            
            guard let sendIntervalType = IntervalType(rawValue: parameters[3]) else {
                return Send("Send interval type must be a valid input (hour, day, week, month).", to: message.RespondTo())
            }
            
            guard let sendTimes = Int(parameters[4]) else {
                return Send("Send times must be an integer.", to: message.RespondTo())
            }
            
            let sendMessage = parameters[5]
            
            let newPost = SchedulePost(value:
                ["sendIntervalNumber" : sendIntervalNumber,
                 "sendIntervalType": sendIntervalType.rawValue,
                 "text": sendMessage,
                 "handle": message.sender.handle,
                 "sendNumberTimes": sendTimes,
                 "handle": message.sender.handle,
                 "startDate": Date(),
                ])
            
            let realm  = try! Realm()
            try! realm.write {
                realm.add(newPost)
            }

            Send("Your post has been succesfully scheduled.", to: message.RespondTo())
            break
        case "delete":
            guard parameters.count > 2 else {
                return Send("The second parameter must be a valid id.", to: message.RespondTo())
            }
            
            guard let deleteID = Int(parameters[2]) else {
                return Send("The delete ID must be an integer.", to: message.RespondTo())
            }
            
            guard deleteID > 0 else {
                return Send("The delete ID must be an positive integer.", to: message.RespondTo())
            }
            
            let schedulePost = realm.objects(SchedulePost.self).filter("handle == %@", message.sender.handle)
            
            guard schedulePost.count >= deleteID  else {
                Send("The specified post ID is not valid.", to: message.RespondTo())
                return
            }
            
            guard schedulePost[deleteID - 1].handle == message.sender.handle else {
                Send("You do not have permission to delete this scheduled message.", to: message.RespondTo())
                return
            }
            
            try! realm.write {
                realm.delete(schedulePost[deleteID - 1])
            }
            Send("The specified scheduled post has been deleted.", to: message.RespondTo())
            
            break
        case "list":
            var scheduledPosts = realm.objects(SchedulePost.self).filter("handle == %@", message.sender.handle)
            scheduledPosts = scheduledPosts.sorted(byKeyPath: "startDate", ascending: false)
            
            var sendMessage = "\(message.sender.givenName ?? "Hello"), you have \(scheduledPosts.count) posts scheduled."
            var iterator = 1
            for post in scheduledPosts {
                sendMessage += "\n\(iterator): Send a message every \(post.sendIntervalNumber) \(post.sendIntervalType)(s) \(post.sendNumberTimes) time(s), starting on \(post.startDate.description(with: Locale.current))."
                iterator += 1
            }
            Send(sendMessage, to: message.RespondTo())
            break
        default:
            Send("Invalid schedule command type. Must be add, delete, or list", to: message.RespondTo())
            break
        }
    }
    
    func changeName(message: Message) {
        guard let parsedMessage = message.getTextParameters() else {
            return Send("Inappropriate input type", to:message.RespondTo())
        }
        
        if (parsedMessage.count == 1) {
            return Send("Wrong arguments.", to: message.RespondTo())
        }
        
        
        guard (CNContactStore.authorizationStatus(for: CNEntityType.contacts) == .authorized) else {
            return Send("Sorry, I do not have access to contacts.", to: message.RespondTo())
        }
        let store = CNContactStore()
        
        let searchPredicate: NSPredicate
        if (!(message.sender.handle.contains("@"))) {
            searchPredicate = CNContact.predicateForContacts(matching: CNPhoneNumber(stringValue: message.sender.handle ?? ""))
        } else {
            searchPredicate = CNContact.predicateForContacts(matchingEmailAddress: message.sender.handle ?? "")
        }
        
        let peopleFound = try! store.unifiedContacts(matching: searchPredicate, keysToFetch:[CNContactFamilyNameKey as CNKeyDescriptor, CNContactGivenNameKey as CNKeyDescriptor])
        
            
        //We need to create the contact
        if (peopleFound.count == 0) {
            // Creating a new contact
            let newContact = CNMutableContact()
            newContact.givenName = parsedMessage[1]
            newContact.note = "Created By Jared.app"
            
            //If it contains an at, add the handle as email, otherwise add it as phone
            if (message.sender.handle.contains("@")) {
                let homeEmail = CNLabeledValue(label: CNLabelHome, value: (message.sender.handle) as NSString)
                newContact.emailAddresses = [homeEmail]
            }
            else {
                let iPhonePhone = CNLabeledValue(label: "iPhone", value: CNPhoneNumber(stringValue:message.sender.handle))
                newContact.phoneNumbers = [iPhonePhone]
            }
        
            let saveRequest = CNSaveRequest()
            saveRequest.add(newContact, toContainerWithIdentifier:nil)
            do {
                try store.execute(saveRequest)
            } catch {
               return Send("There was an error saving your contact..", to: message.RespondTo())
            }
            
            Send("Ok, I'll call you \(parsedMessage[1]) from now on.", to: message.RespondTo())
        }
        //The contact already exists, modify the value
        else {
            let mutableContact = peopleFound[0].mutableCopy() as! CNMutableContact
            mutableContact.givenName = parsedMessage[1]
            
            let saveRequest = CNSaveRequest()
            saveRequest.update(mutableContact)
            try! store.execute(saveRequest)
            
            Send("Ok, I'll call you \(parsedMessage[1]) from now on.", to: message.RespondTo())
        }
    }
}
