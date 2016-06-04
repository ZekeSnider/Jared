//
//  main.swift
//  EmoteModule
//
//  Created by Zeke Snider on 4/16/16.
//  Copyright © 2016 Zeke Snider. All rights reserved.
//

import Foundation
import JaredFramework

public class EmoteModule: RoutingModule {
    public var routes: [Route] = []
    public var description = "A Description"

    required public init() {
        let fuccboi = Route(name: "test function", comparisons: [.StartsWith: ["/moduletest"]], call: self.test, description: "TEST")
        routes = [fuccboi]
    }
    
    public func test(message:String, myRoom: Room) -> Void {
        SendText("Nigga this command was loaded from a modularized bundle", toRoom: myRoom)
    }
}


