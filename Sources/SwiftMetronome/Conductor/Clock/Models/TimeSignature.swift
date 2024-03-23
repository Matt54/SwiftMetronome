//
//  TimeSignature.swift
//  SpatialTuner
//
//  Created by Matt Pfeiffer on 3/16/24.
//

import Foundation

public enum TimeSignature: CaseIterable {
    case commonTime
    case threeFour
    case twoFour
    case sixEight
    case twelveEight
    case cutTime

    var name: String {
        switch self {
        case .commonTime:
            return "Common Time"
        case .threeFour:
            return "Waltz Time"
        case .twoFour:
            return "March Time"
        case .sixEight:
            return "Jig Time"
        case .twelveEight:
            return "Blues Time"
        case .cutTime:
            return "Cut Time"
        }
    }
    
    // Because a SwiftUI menu only spaces out when using Text - Icon
    var menuTextHacked: String {
        switch self {
        case .commonTime:
            "Common Time             \(fractionText)"
        case .threeFour:
            "Waltz Time                   \(fractionText)"
        case .twoFour:
            "March Time                  \(fractionText)"
        case .sixEight:
            "Jig Time                        \(fractionText)"
        case .twelveEight:
            "Blues Time                  \(fractionText)"
        case .cutTime:
            "Cut Time                       \(fractionText)"
        }
    }
    
    var menuText: String {
        fractionText + " (\(name))"
    }
    
    var fractionText: String {
        "\(numerator) / \(denominator)"
    }

    var numerator: Int {
        switch self {
        case .commonTime:
            return 4
        case .threeFour:
            return 3
        case .twoFour:
            return 2
        case .sixEight:
            return 6
        case .twelveEight:
            return 12
        case .cutTime:
            return 2
        }
    }

    var denominator: Int {
        switch self {
        case .commonTime, .threeFour, .twoFour:
            return 4
        case .sixEight, .twelveEight:
            return 8
        case .cutTime:
            return 2
        }
    }
}
