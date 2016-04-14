//
//  EpicModule.swift
//  Jared
//
//  Created by Jared Derulo on 4/12/16.
//  Copyright © 2016 Zeke Snider. All rights reserved.
//


import Foundation
import Cocoa
struct EpicModule: RoutingModule {
    var routes: [Route] = []
    var description = "Contains a lot of epic commands with personality"
    
    init() {
        let fuccboi = Route(comparisons: [.StartsWith: "/fuccboi"], call: self.youreFuccboi, description: "Call Jared a fuccboi")
        let tip = Route(comparisons: [.StartsWith: "/tip"], call: self.tipBuddy, description: "Tip your fedora to a fellow gentlesir", parameterSyntax: ["/tip,[Name of friend (optional)]"])
        let bazinga = Route(comparisons: [.StartsWith: "/bazinga"], call: self.sendBazing, description: "Become epic like sheldon cooper")
        let nice = Route(comparisons: [.StartsWith: "/nice"], call: self.sendNice, description: "Congratulate someone on an epic accomplishment")
        let stop = Route(comparisons: [.Contains: "stop"], call: self.dontStop, description: "Stop Jared")
        let hello = Route(comparisons: [.Contains: "hello"], call: self.sendHello, description: "Say hello to Jared")
        let rate = Route(comparisons: [.StartsWith: "/10"], call: self.rateMessage, description: "Rate out of 10")
        let bigBunny = Route(comparisons: [.Contains: "Hey jared please send me the big buck bunny movie trailer"], call: self.bigBunny, description: "Send the big buck bunny movie trailer")
        let slots = Route(comparisons: [.StartsWith: "/slots"], call: self.spinSlots, description: "Play slots")
        let kill = Route(comparisons: [.StartsWith: "/kill"], call: self.killJared, description: "Kill Jared")
        let clear = Route(comparisons: [.StartsWith: "/clear"], call: self.clearChat, description: "Clear the chat")
        
        routes = [fuccboi, tip, bazinga, nice, stop, hello, rate, bigBunny, slots, kill, clear]
    }
    
    func bigBunny(message:String, myRoom: Room) -> Void{
        SendText("Sure thing, buddy!", toRoom: myRoom)
        if let MoviePath = NSBundle.mainBundle().pathForResource("Big_Buck_Bunny_Trailer", ofType: "m4v") {
            SendImage(MoviePath, toRoom: myRoom)
        }
    }
    
    func youreFuccboi(message:String, myRoom: Room) -> Void{
        if let theBuddy = myRoom.buddyName {
            SendText("No \(theBuddy), you're the fuccboi", toRoom: myRoom)
        }
        
    }
    
    func tipBuddy(message:String, myRoom: Room) -> Void {
        let FedoPath = NSBundle.mainBundle().pathForResource("Fedora", ofType: "jpg")
        let parameters = message.componentsSeparatedByString(",")
        let tipText = "I tip my fedora to thee!"
        
        if let FedoImage = FedoPath {
            SendImage(FedoImage, toRoom: myRoom)
        }
        
        if let tipReceiver = parameters[safe: 1] {
            SendText("\(tipReceiver), \(tipText)", toRoom: myRoom)
        }
        else {
            SendText("\(tipText)", toRoom: myRoom)
        }
    }
    
    func sendBazing(message:String, myRoom: Room) -> Void{
        let bazingas: [String] = ["BAZINGO", "BAZGOBO", "BANZANGO", "BAGELBITES", "BAZGO", "BENGHAZI", "BONANZA", "BANANABOY", "BONOBO", "BOZANGLO", "BANJOKAZOOIE", "BONGOZONE", "BOINGZAPPO", "BACKBONE", "BRASILIA", "BAGBOY","BUMBERTUNGUS", "BAPTISMA", "BADZEBRA", "BOGOMBGA", "BANJUL", "BANGUI", "BOPUMBZO"]
        let bazing = bazingas[Int(arc4random_uniform(UInt32(bazingas.count)))]
        SendText("\(bazing)!", toRoom: myRoom)
    }
    
    func sendNice(message:String, myRoom: Room) -> Void {
        SendText("Wow, what a nice epic funnyjoke my friend!", toRoom: myRoom)
    }
    
    func dontStop(message:String, myRoom: Room) -> Void {
        if let theBuddy = myRoom.buddyName {
            for _ in 1...5 {
                SendText("Fuck off \(theBuddy) I dont stop for anyone", toRoom: myRoom)
            }
        }
    }
    
    func sendHello(message:String, myRoom: Room) -> Void {
        if let theBuddy = myRoom.buddyName {
            SendText("Hello \(theBuddy)", toRoom: myRoom)
        }
    }
    
    func rateMessage(message:String, myRoom: Room) -> Void {
        let parameters = message.componentsSeparatedByString(",")
        let rando = Int(arc4random_uniform(11))
        
        if let ratingReceiver = parameters[safe: 1] {
            SendText("Wow \(ratingReceiver), I give that post a \(rando)/10!", toRoom: myRoom)
        }
        else {
            SendText("I give that post a \(rando)/10!", toRoom: myRoom)
        }
    }
    
    func spinSlots(message:String, myRoom: Room) -> Void {
        let s1 = Int(arc4random_uniform(7)) + 1
        let s2 = Int(arc4random_uniform(7)) + 1
        let s3 = Int(arc4random_uniform(7)) + 1
        let s4 = Int(arc4random_uniform(500))
        
        if s4 == 100
        {
            SendText("JEW | JEW | JEW\nYOU WIN!!!", toRoom: myRoom)
        }
        else {
            SendText("\(s1) | \(s2) | \(s3)", toRoom: myRoom)
            if s1 == 7 && s2 == 7 && s3 == 7 {
                SendText("Nice! You get the Jared seal of approval", toRoom: myRoom)
            }
            if s1 == 6 && s2 == 6 && s3 == 6 {
                SendText("lol u r the devil", toRoom: myRoom)
            }
        }
    }
    
    func killJared(message:String, myRoom: Room) -> Void {
        if let theBuddy = myRoom.buddyName {
            SendText("fite me irl \(theBuddy)", toRoom: myRoom)
        }
    }
    
    func clearChat(message:String, myRoom: Room) -> Void {
        SendText("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n:^)", toRoom: myRoom)
    }
}
