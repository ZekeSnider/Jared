//
//  File.swift
//  Jared
//
//  Created by Zeke Snider on 4/20/20.
//  Copyright © 2020 Zeke Snider. All rights reserved.
//

import Foundation
import JaredFramework

protocol PluginManagerDelegate {
    func getAllRoutes() -> [Route]
    func getAllModules() -> [RoutingModule]
    func reload()
    func enabled(routeName: String) -> Bool
}
