//
//  LogsMetronomeEvents.swift
//  
//
//  Created by Matt Pfeiffer on 3/21/24.
//

import Foundation

public protocol LogsMetronomeEvents {
    static func log(_ eventName: String, additionalContext: [String: Any]?)
}
