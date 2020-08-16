//
//  AutomationPermissionState.swift
//  Jared
//
//  Created by Zeke Snider on 8/16/20.
//  Copyright © 2020 Zeke Snider. All rights reserved.
//

import Foundation

enum AutomationPermissionState: Int {
    case declined
    case authorized
    case notDetermined
    case notRunning
    case unknown
}
