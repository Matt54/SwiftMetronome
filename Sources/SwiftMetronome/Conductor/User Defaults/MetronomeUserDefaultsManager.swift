//
//  MetronomeUserDefaultsManager.swift
//  SpatialTuner
//
//  Created by Matt Pfeiffer on 3/16/24.
//

import Foundation

class MetronomeUserDefaultsManager {
    enum UserDefaultKey: String {
        case soundType = "kSoundType"
    }
    
    static func getMetronomeSoundType() -> MetronomeSound {
        let key = UserDefaultKey.soundType.rawValue
        let value = UserDefaults.standard.string(forKey: key)
        let soundType = MetronomeSound(rawValue: value ?? "")
        return soundType ?? .defaultClick
    }
    
    static func setMetronomeSoundType(_ value: MetronomeSound) {
        UserDefaults.standard.set(Int(value.rawValue), forKey: UserDefaultKey.soundType.rawValue)
    }
}
