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
import AddressBook
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
        backgroundThread(0.0, background: {
            self.scheduleThread()
        })
    }
    
    
    func pingCall(_ message:String, myRoom: Room) -> Void {
        SendText(NSLocalizedString("PongResponse"), toRoom: myRoom)
    }
    
    func getWho(_ message:String, myRoom: Room) -> Void {
        if myRoom.buddyName != "" {
            SendText("Your name is \(myRoom.buddyName!).", toRoom: myRoom)
        }
        else {
            SendText("I don't know your name.", toRoom: myRoom)
        }
    }
    
    func thanksJared(_ message:String, myRoom: Room) -> Void {
        SendText(NSLocalizedString("WelcomeResponse"), toRoom: myRoom)
    }
    
    func getVersion(_ message:String, myRoom: Room) -> Void {
        SendText(NSLocalizedString("versionResponse"), toRoom: myRoom)
    }
    
    var guessMin: Int? = 0
    
    func sendRepeat(_ message:String, myRoom: Room) -> Void {
        let parameters = message.components(separatedBy: ",")
        
        //Validating and parsing arguments
        guard let repeatNum: Int = Int(parameters[1]) else {
            SendText("Wrong argument. The first argument must be the number of message you wish to send", toRoom: myRoom)
            return
        }
        
        guard let delay = Int(parameters[2]) else {
            SendText("Wrong argument. The second argument must be the delay of the messages you wish to send", toRoom: myRoom)
            return
        }
        
        guard var textToSend = parameters[safe: 3] else {
            SendText("Wrong arguments. The third argument must be the message you wish to send.", toRoom: myRoom)
            return
        }
        
        guard myRoom.buddyHandle != nil else {
            SendText("You must have a proper handle.", toRoom: myRoom)
            return
        }
        
        guard (currentSends[myRoom.buddyHandle!] ?? 0) < MAXIMUM_CONCURRENT_SENDS else {
            SendText("You can only have \(MAXIMUM_CONCURRENT_SENDS) send operations going at once.", toRoom: myRoom)
            return
        }
        
        if (currentSends[myRoom.buddyHandle!] == nil)
        {
            currentSends[myRoom.buddyHandle!] = 0
        }
        
        //Increment the concurrent send counter for this user
        currentSends[myRoom.buddyHandle!] = currentSends[myRoom.buddyHandle!]! + 1
        
        //If there are commas in the message, take the whole message
        if parameters.count > 4 {
            textToSend = parameters[3...(parameters.count - 1)].joined(separator: ",")
        }
        
        //Go through the repeat loop...
        for _ in 1...repeatNum {
            SendText(textToSend, toRoom: myRoom)
            Thread.sleep(forTimeInterval: Double(delay))
        }
        
        //Decrement the concurrent send counter for this user
        currentSends[myRoom.buddyHandle!] = (currentSends[myRoom.buddyHandle!] ?? 0) - 1
        
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
                    let sendRoom = Room(GUID: post.chatID, buddyName: "", buddyHandle: post.handle)
                    SendText(post.text, toRoom: sendRoom)
                    try! realm.write {
                        post.lastSendDate = Date()
                    }
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
    
    func schedule(_ myMessage: String, forRoom: Room) {
        // /schedule,add,1,week,5,full Message
        // /schedule,delete,1
        // /schedule,list
        let parameters = myMessage.components(separatedBy: ",")
        
        guard forRoom.buddyHandle != nil else {
            SendText("Buddy must have valid handle.", toRoom: forRoom)
            return
        }
        guard parameters.count > 1 else {
            SendText("More parameters required.", toRoom: forRoom)
            return
        }
        
        let realm  = try! Realm()
        
        switch parameters[1] {
        case "add":
            guard parameters.count > 5 else {
                SendText("Incorrect number of parameters specified.", toRoom: forRoom)
                return
            }
            
            guard let sendIntervalNumber = Int(parameters[2]) else {
                SendText("Send interval number must be an integer.", toRoom: forRoom)
                return
            }
            
            guard let sendIntervalType = IntervalType(rawValue: parameters[3]) else {
                SendText("Send interval type must be a valid input (hour, day, week, month).", toRoom: forRoom)
                return
            }
            
            guard let sendTimes = Int(parameters[4]) else {
                SendText("Send times must be an integer.", toRoom: forRoom)
                return
            }
            
            let sendMessage = parameters[5]
            
            let newPost = SchedulePost(value:
                ["sendIntervalNumber" : sendIntervalNumber,
                 "sendIntervalType": sendIntervalType.rawValue,
                 "text": sendMessage,
                 "handle": forRoom.buddyHandle!,
                 "sendNumberTimes": sendTimes,
                 "chatID": forRoom.GUID ?? "",
                 "startDate": Date(),
                ])
            
            let realm  = try! Realm()
            try! realm.write {
                realm.add(newPost)
            }

            SendText("Your post has been succesfully scheduled.", toRoom: forRoom)
            break
        case "delete":
            guard parameters.count > 2 else {
                SendText("The second parameter must be a valid id.", toRoom: forRoom)
                return
            }
            
            guard let deleteID = Int(parameters[2]) else {
                SendText("The delete ID must be an integer.", toRoom: forRoom)
                return
            }
            
            guard deleteID > 0 else {
                SendText("The delete ID must be an positive integer.", toRoom: forRoom)
                return
            }
            
            let schedulePost = realm.objects(SchedulePost.self).filter("handle == %@", forRoom.buddyHandle!)
            
            guard schedulePost.count >= deleteID  else {
                SendText("The specified post ID is not valid.", toRoom: forRoom)
                return
            }
            
            guard schedulePost[deleteID - 1].handle == forRoom.buddyHandle else {
                SendText("You do not have permission to delete this scheduled message.", toRoom: forRoom)
                return
            }
            
            try! realm.write {
                realm.delete(schedulePost[deleteID - 1])
            }
            SendText("The specified scheduled post has been deleted.", toRoom: forRoom)
            
            break
        case "list":
            var scheduledPosts = realm.objects(SchedulePost.self).filter("handle == %@", forRoom.buddyHandle!)
            scheduledPosts = scheduledPosts.sorted(byKeyPath: "startDate", ascending: false)
            
            var sendMessage = "\(forRoom.buddyName ?? "Hello"), you have \(scheduledPosts.count) posts scheduled."
            var iterator = 1
            for post in scheduledPosts {
                sendMessage += "\n\(iterator): Send a message every \(post.sendIntervalNumber) \(post.sendIntervalType)(s) \(post.sendNumberTimes) time(s), starting on \(post.startDate.description(with: Locale.current))."
                iterator += 1
            }
            SendText(sendMessage, toRoom: forRoom)
            break
        default:
            SendText("Invalid schedule command type. Must be add, delete, or list", toRoom: forRoom)
            break
        }
    }
    
    func changeName(_ myMessage: String, forRoom: Room) {
        let parsedMessage = myMessage.components(separatedBy: ",")
        if (parsedMessage.count == 1) {
            SendText("Wrong arguments.", toRoom: forRoom)
            return
        }
        
        guard forRoom.buddyHandle != nil && forRoom.buddyHandle != "" else {
            SendText("I can't set name for a buddy with no handle...", toRoom: forRoom)
            return
        }
        let store = CNContactStore()
        
        //Attempt to open the address book
        if let book = ABAddressBook.shared() {
            let emailSearchElement = ABPerson.searchElement(forProperty: kABEmailProperty, label: nil, key: nil, value: forRoom.buddyHandle, comparison: ABSearchComparison(kABEqualCaseInsensitive.rawValue))
            let phoneSearchElement = ABPerson.searchElement(forProperty: kABPhoneProperty, label: nil, key: nil, value: forRoom.buddyHandle, comparison: ABSearchComparison(kABEqualCaseInsensitive.rawValue))
            let bothSearchElement = ABSearchElement(forConjunction: ABSearchConjunction(kABSearchOr.rawValue), children: [emailSearchElement!, phoneSearchElement!])
            let peopleFound = book.records(matching: bothSearchElement)
            
            //We need to create the contact
            if (peopleFound?.count == 0) {
                // Creating a new contact
                let newContact = CNMutableContact()
                newContact.givenName = parsedMessage[1]
                newContact.note = "Created By Jared.app"
                
                //If it contains an at, add the handle as email, otherwise add it as phone
                if (forRoom.buddyHandle!.contains("@")) {
                    let homeEmail = CNLabeledValue(label: CNLabelHome, value: (forRoom.buddyHandle ?? "") as NSString)
                    newContact.emailAddresses = [homeEmail]
                }
                else {
                    let iPhonePhone = CNLabeledValue(label: "iPhone", value: CNPhoneNumber(stringValue:forRoom.buddyHandle ?? ""))
                    newContact.phoneNumbers = [iPhonePhone]
                }
            
                let saveRequest = CNSaveRequest()
                saveRequest.add(newContact, toContainerWithIdentifier:nil)
                do {
                    try store.execute(saveRequest)
                } catch {
                    SendText("There was an error saving your contact..", toRoom: forRoom)
                    return
                }
                
                SendText("Ok, I'll call you \(parsedMessage[1]) from now on.", toRoom: forRoom)
                
            }
                //The contact already exists, modify the value
            else {
                let myPerson = peopleFound?[0] as! ABRecord
                ABRecordSetValue(myPerson, kABFirstNameProperty as CFString, parsedMessage[1] as CFTypeRef)
                
                book.save()
                SendText("Ok, I'll call you \(parsedMessage[1]) from now on.", toRoom: forRoom)
            }
        }
            //If we do not have permission to access contacts
        else {
            SendText("Sorry, I do not have access to contacts.", toRoom: forRoom)
        }
    }
}
