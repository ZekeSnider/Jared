//
//  Route.swift
//  JaredFramework
//
//  Created by Zeke Snider on 2/3/19.
//  Copyright © 2019 Zeke Snider. All rights reserved.
//

import Foundation

public enum Compare {
    case startsWith
    case contains
    case `is`
    case containsURL
}

public struct Route {
    public var name: String
    public var comparisons: [Compare: [String]]
    public var parameterSyntax: String?
    public var description: String?
    public var call: (Message) -> Void
    
    public init(name: String, comparisons:[Compare: [String]], call: @escaping (Message) -> Void) {
        self.name = name
        self.comparisons = comparisons
        self.call = call
    }
    public init(name: String, comparisons:[Compare: [String]], call: @escaping (Message) -> Void, description: String) {
        self.name = name
        self.comparisons = comparisons
        self.call = call
        self.description = description
    }
    public init(name: String, comparisons:[Compare: [String]], call: @escaping (Message) -> Void, description: String, parameterSyntax: String) {
        self.name = name
        self.comparisons = comparisons
        self.call = call
        self.description = description
        self.parameterSyntax = parameterSyntax
    }
}

public protocol RoutingModule {
    var routes: [Route] {get}
    var description: String {get}
    init()
}
