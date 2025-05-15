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
        case boostType = "kBoostType"
    }
    
    static func getMetronomeSoundType() -> MetronomeSound {
        let key = UserDefaultKey.soundType.rawValue
        let value = UserDefaults.standard.string(forKey: key)
        let soundType = MetronomeSound(rawValue: value ?? "")
        return soundType ?? .defaultClick
    }
    
    static func setMetronomeSoundType(_ value: MetronomeSound) {
        UserDefaults.standard.set(value.rawValue, forKey: UserDefaultKey.soundType.rawValue)
        
    }
    
    static func getMetronomeBoostType() -> BoostType {
        let key = UserDefaultKey.boostType.rawValue
        let value = UserDefaults.standard.string(forKey: key)
        let boostType = BoostType(rawValue: value ?? "")
        return boostType ?? .normal
    }
    
    static func setMetronomeBoostType(_ value: BoostType) {
        UserDefaults.standard.set(value.rawValue, forKey: UserDefaultKey.boostType.rawValue)
    }
}
