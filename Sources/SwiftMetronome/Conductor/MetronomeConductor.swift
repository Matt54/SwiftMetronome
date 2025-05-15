//
//  Metronome.swift
//  SpatialTuner
//
//  Created by Matt Pfeiffer on 2/29/24.
//

import AudioKit
import AVFoundation

// MARK: Properties and Initializer
@Observable
public class MetronomeConductor {
    public var clock = TickCountingTimer()
    public var soundType: MetronomeSound = MetronomeUserDefaultsManager.getMetronomeSoundType() {
        didSet { setSoundType(soundType) }
    }
    public var boostType: BoostType = MetronomeUserDefaultsManager.getMetronomeBoostType() {
        didSet { setBoostType(boostType) }
    }
    public var errorMessage: String? = nil
    public var Logger: LogsMetronomeEvents.Type? // logger / analytics capturing class
    public var instanceCount: Int = 0
    
    private var engineIsRunning: Bool = false
    private var engine: AudioEngine
    private var outputMixer: Mixer = Mixer()
    private var primaryHitSampler = AppleSampler()
    private var secondaryHitSampler = AppleSampler()
    
    public init(Logger: LogsMetronomeEvents.Type? = nil)  {
        self.Logger = Logger
        engine = AudioEngine()
        #if !targetEnvironment(simulator)
        setupAudioChain()
        configureAudioSession()
        outputMixer.volume = boostType.mixerOutputVolume
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleAudioSessionInterruption), name: AVAudioSession.interruptionNotification, object: AVAudioSession.sharedInstance())
        #endif
    }
}

// MARK: Public Methods
public extension MetronomeConductor {
    /// Starts and then stops the audio engine - I call this on app launch and it seems to prepare the system for playback. I was getting a nasty sound when playback started for the first time otherwise.
    func warmupEngine() {
        do {
            try engine.start()
            engine.stop()
            Logger?.log(MetronomeEvent.audioEngineWarmup.rawValue,
                        additionalContext: ["object": "Metronome"])
        } catch {
            Logger?.log(MetronomeEvent.audioEngineWarmupError.rawValue,
                        additionalContext: ["object": "Metronome",
                                            "error" : String(describing: error)])
            errorMessage = error.localizedDescription
        }
    }
    
    func resume() {
        do {
            // the samplers wipe the audio files when the engine stops, so load them back each time
            try loadAudioSamplesForSoundType(soundType)
            try engine.start()
            engineIsRunning = true
            Logger?.log(MetronomeEvent.audioEngineStarted.rawValue,
                        additionalContext: ["object": "Metronome"])
            clock.resume()
        } catch {
            Logger?.log(MetronomeEvent.audioEngineStartError.rawValue,
                        additionalContext: ["object": "Metronome",
                                            "error" : String(describing: error)])
            engineIsRunning = false
            clock.pause()
            errorMessage = error.localizedDescription
        }
    }
    
    func pause() {
        clock.pause()
        engine.stop()
        engineIsRunning = false
        Logger?.log(MetronomeEvent.audioEngineStopped.rawValue, additionalContext: ["object": "Metronome"])
    }
    
    func setSoundType(_ soundType: MetronomeSound) {
        do {
            try loadAudioSamplesForSoundType(soundType)
            MetronomeUserDefaultsManager.setMetronomeSoundType(soundType)
            Logger?.log(MetronomeEvent.soundTypeChanged.rawValue,
                        additionalContext: ["object": "Metronome",
                                            "soundType": soundType.rawValue])
        } catch {
            Logger?.log(MetronomeEvent.soundTypeChangeError.rawValue,
                        additionalContext: ["object": "Metronome",
                                            "soundType": soundType.rawValue,
                                            "error": String(describing: error)])
            errorMessage = error.localizedDescription
        }
    }
    
    func setBoostType(_ boostType: BoostType) {
        outputMixer.volume = boostType.mixerOutputVolume
        MetronomeUserDefaultsManager.setMetronomeBoostType(boostType)
    }
}

// MARK: Private Methods
extension MetronomeConductor {
    func setupAudioChain() {
        outputMixer.addInput(primaryHitSampler)
        outputMixer.addInput(secondaryHitSampler)
        
        // Set the hit callback to call the playHitSound method
        clock.tickEventCallback = { [weak self] hitType in
            self?.playSoundForClockTickEvent(hitType)
        }
        
        engine.output = outputMixer
    }
    
    func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setIntendedSpatialExperience(.bypassed)
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: [.mixWithOthers, .allowBluetooth, .defaultToSpeaker])
            try audioSession.setActive(true)
        } catch {
            Logger?.log(MetronomeEvent.setAudioSessionCategoryError.rawValue,
                        additionalContext: ["object": "Metronome",
                                            "error": String(describing: error)])
        }
    }
    
    func loadAudioSamplesForSoundType(_ soundType: MetronomeSound) throws {
        guard let primaryHitURL = Bundle.module.url(forResource: soundType.hiFile, withExtension: nil)
        else { throw MetronomeError.primarySoundMissing }
        
        guard let secondaryHitURL = Bundle.module.url(forResource: soundType.loFile, withExtension: nil)
        else { throw MetronomeError.secondarySoundMissing }
        
        let primaryAudioFile = try AVAudioFile(forReading: primaryHitURL)
        let secondaryAudioFile = try AVAudioFile(forReading: secondaryHitURL)
        
        try primaryHitSampler.loadAudioFile(primaryAudioFile)
        try secondaryHitSampler.loadAudioFile(secondaryAudioFile)
    }
    
    /// Play the hit sound based on the hit type
    func playSoundForClockTickEvent(_ hitType: TickEventType) {
        let subHitDifference: UInt8 = 37 // subdivision hits are a little quieter version of secondary
        
        switch hitType {
        case .primary:
            primaryHitSampler.play(noteNumber: 60, velocity: soundType.velocity)
        case .secondary:
            secondaryHitSampler.play(noteNumber: 60, velocity: soundType.velocity)
        case .subdivision:
            secondaryHitSampler.play(noteNumber: 60, velocity: soundType.velocity-subHitDifference)
        }
    }
    
    @objc func handleAudioSessionInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo else {
            Logger?.log(MetronomeEvent.audioEngineInterruptionUnknown.rawValue,
                        additionalContext: ["object": "Metronome"])
            return
        }
        
        var stringKeyedUserInfo: [String: Any] = userInfo.reduce(into: [String: Any]()) { result, pair in
            if let key = pair.key as? String {
                result[key] = pair.value
            }
        }

        stringKeyedUserInfo.merge(["object": "Metronome"]) { (current, _) in current }

        Logger?.log(MetronomeEvent.audioEngineInterruption.rawValue,
                    additionalContext: stringKeyedUserInfo)
        
        guard let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
                let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        

        if type == .began {
            pause()
        } else if type == .ended {
            do {
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                stringKeyedUserInfo.merge(["error": String(describing: error)]) { (current, _) in current }
                Logger?.log(MetronomeEvent.audioSessionSetActiveFailed.rawValue,
                            additionalContext: stringKeyedUserInfo)
            }
        }
    }
}

// MARK: MetronomeError
enum MetronomeError: Error {
    case primarySoundMissing, secondarySoundMissing
}

// MARK: BoostType
public enum BoostType: String, CaseIterable {
    case quiet
    case normal
    case loud
    
    var name: String {
        switch self {
        case .quiet:
            "Quiet"
        case .normal:
            "Normal"
        case .loud:
            "Loud"
        }
    }
    
    var mixerOutputVolume: Float {
        switch self {
        case .quiet:
            return 0.75
        case .normal:
            return 1.5
        case .loud:
            return 2.25
        }
    }
}
