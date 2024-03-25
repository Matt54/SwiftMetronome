//
//  MetronomeEvent.swift
//  
//
//  Created by Matt Pfeiffer on 3/21/24.
//

import Foundation

enum MetronomeEvent: String {
    case audioEngineWarmup = "Audio Engine Warmup",
         audioEngineStarted = "Audio Engine Started",
         audioEngineStopped = "Audio Engine Stopped",
         setAudioSessionCategoryError = "Set Audio Session Category Error",
         audioEngineInterruption = "Audio Engine Interruption",
         audioEngineInterruptionUnknown = "Audio Engine Interruption Unknown",
         audioSessionSetActiveFailed = "Audio Session Set Active Failed",
         audioEngineWarmupError = "Audio Engine Warmup Error",
         audioEngineStartError = "Audio Engine Start Error",
         soundTypeChanged = "Sound Type Changed",
         soundTypeChangeError = "Sound Type Change Error"
}
