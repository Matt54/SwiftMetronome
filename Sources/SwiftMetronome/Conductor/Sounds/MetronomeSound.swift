//
//  MetronomeSound.swift
//  SpatialTuner
//
//  Created by Matt Pfeiffer on 3/15/24.
//

import Foundation

public enum MetronomeSound: String, CaseIterable {
    case defaultClick = "Default"
    case synthWeirdC = "Synth_Weird_C"
    case synthWeirdB = "Synth_Weird_B"
    case synthWeirdA = "Synth_Weird_A"
    case synthTickB = "Synth_Tick_B"
    case synthTickA = "Synth_Tick_A"
    case synthSquareC = "Synth_Square_C"
    case synthSquareB = "Synth_Square_B"
    case synthSquareA = "Synth_Square_A"
    case synthSine = "Synth_Sine"
    case synthBlockE = "Synth_Block_E"
    case synthBlockD = "Synth_Block_D"
    case synthBlockC = "Synth_Block_C"
    case synthBlockB = "Synth_Block_B"
    case synthBlockA = "Synth_Block_A"
    case synthBellB = "Synth_Bell_B"
    case synthBellA = "Synth_Bell_A"
    case percWhistleParty = "Perc_WhistleParty"
    case percTongue = "Perc_Tongue"
    case percTeeth = "Perc_Teeth"
    case percTambA = "Perc_Tamb"
    case percSnap = "Perc_Snap"
    case percMusicStand = "Perc_MusicStand"
    case percMouthPop = "Perc_MouthPop"
    case percMetronomeQuartz = "Perc_MetronomeQuartz"
    case percHeadKnock = "Perc_HeadKnock"
    case percGlass = "Perc_Glass"
    case percClickToy = "Perc_ClickToy"
    case percClap = "Perc_Clap"
    case percClackhead = "Perc_Clackhead"
    case percCastanet = "Perc_Castanet"
    case percCan = "Perc_Can"

    var hiFile: String {
        return "\(self.rawValue)_hi.wav"
    }

    var loFile: String {
        return "\(self.rawValue)_lo.wav"
    }
    
    var velocity: UInt8 {
        switch self {
        case .defaultClick:
            90
        default:
            127
        }
    }

    var name: String {
        return self.rawValue
            .replacingOccurrences(of: "Synth_", with: "")
            .replacingOccurrences(of: "Perc_", with: "")
            .replacingOccurrences(of: "_", with: " ")
            .addingSpacesBetweenCapitalizedWords()
    }
    
    static var sortedByName: [MetronomeSound] {
        allCases.sorted { $0.name < $1.name }
    }
}

extension String {
    func addingSpacesBetweenCapitalizedWords() -> String {
        var result = ""
        for character in self {
            if character.isUppercase {
                result += " " + String(character)
            } else {
                result += String(character)
            }
        }
        return result.trimmingCharacters(in: .whitespaces)
    }
}
