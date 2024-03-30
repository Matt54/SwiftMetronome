//
//  TempoMarking.swift
//
//
//  Created by Matt Pfeiffer on 3/29/24.
//

import Foundation

enum TempoMarking: String {
    case larghissimo = "Larghissimo"
    case grave = "Grave"
    case largo = "Largo"
    case larghetto = "Larghetto"
    case adagio = "Adagio"
    case adagietto = "Adagietto"
    case andante = "Andante"
    case andantino = "Andantino"
    case moderato = "Moderato"
    case allegretto = "Allegretto"
    case allegro = "Allegro"
    case vivace = "Vivace"
    case presto = "Presto"
    case prestissimo = "Prestissimo"

    static func fromTempo(_ tempo: Double) -> TempoMarking {
        switch tempo {
        case ..<20: return .larghissimo
        case 20..<40: return .grave
        case 40..<60: return .largo
        case 60..<66: return .larghetto
        case 66..<76: return .adagio
        case 76..<108: return .andante
        case 108..<120: return .moderato
        case 120..<168: return .allegro
        case 168..<200: return .vivace
        case 200..<208: return .presto
        case 208...: return .prestissimo
        default: return .moderato // Default case for tempos not covered above
        }
    }
}
