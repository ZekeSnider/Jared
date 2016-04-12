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
    init() {
        let fuccboi = Route(comparisons: [.StartsWith: "/fuccboi"], call: self.youreFuccboi)
        let tip = Route(comparisons: [.StartsWith: "/tip"], call: self.tipBuddy)
        let bazinga = Route(comparisons: [.StartsWith: "/bazinga"], call: self.sendBazing)
        let nice = Route(comparisons: [.StartsWith: "/nice"], call: self.sendNice)
        let stop = Route(comparisons: [.Contains: "stop"], call: self.dontStop)
        let hello = Route(comparisons: [.Contains: "hello"], call: self.sendHello)
        let rate = Route(comparisons: [.StartsWith: "/10"], call: self.rateMessage)
        let bigBunny = Route(comparisons: [.Contains: "Hey jared please send me the big buck bunny movie trailer"], call: self.bigBunny)
        
        routes = [fuccboi, tip, bazinga, nice, stop, hello, rate, bigBunny]
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
}
