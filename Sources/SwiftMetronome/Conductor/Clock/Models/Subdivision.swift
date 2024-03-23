//
//  Subdivision.swift
//  SpatialTuner
//
//  Created by Matt Pfeiffer on 3/16/24.
//

import Foundation

public enum Subdivision: CaseIterable {
    case one
    case two
    case three
    case four
    
    func getNameForTimeSignature(_ timeSignature: TimeSignature) -> String {
        if timeSignature.denominator == 2 {
            switch self {
            case .one:
                return "Half"
            case .two:
                return "Quarter"
            case .three:
                return "Triplet Quarter"
            case .four:
                return "Eighth"
            }
        } else if timeSignature.denominator == 8 {
            switch self {
            case .one:
                return "Eighth"
            case .two:
                return "Sixteenth"
            case .three:
                return "Triplet Sixteenth"
            case .four:
                return "Thirty-Second"
            }
        } else {
            switch self {
            case .one:
                return "Quarter"
            case .two:
                return "Eighth"
            case .three:
                return "Triplet Eighth"
            case .four:
                return "Sixteenth"
            }
        }
    }
    
    func getImageForTimeSignature(_ timeSignature: TimeSignature) -> String {
        if timeSignature.denominator == 2 {
            switch self {
            case .one:
                return "single_half_division"
            case .two:
                return "double_quarter_division"
            case .three:
                return "triplet_quarter_division"
            case .four:
                return "quad_eighth_division"
            }
        } else if timeSignature.denominator == 8 {
            switch self {
            case .one:
                return "single_eighth_division"
            case .two:
                return "double_sixteenth_division"
            case .three:
                return "triplet_sixteenth_division"
            case .four:
                return "quad_32_division"
            }
        } else {
            switch self {
            case .one:
                return "single_quarter_division"
            case .two:
                return "double_eighth_division"
            case .three:
                return "triplet_eighth_division"
            case .four:
                return "quad_sixteenth_division"
            }
        }
    }
    
    var divisionsPerBeat: UInt32 {
        switch self {
        case .one:
            1
        case .two:
            2
        case .three:
            3
        case .four:
            4
        }
    }
}
