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
    public var soundType = MetronomeUserDefaultsManager.getMetronomeSoundType() {
        didSet { setSoundType(soundType) }
    }
    public var errorMessage: String? = nil
    public var Logger: LogsMetronomeEvents.Type? // logger / analytics capturing class
    
    private var engineIsRunning: Bool = false
    private var engine: AudioEngine
    private var outputMixer: Mixer = Mixer()
    private var primaryHitSampler = AppleSampler()
    private var secondaryHitSampler = AppleSampler()
    private var wasRunning: Bool = false // keeps track of play state during audio interruption
    
    public init(Logger: LogsMetronomeEvents.Type? = nil)  {
        self.Logger = Logger
        engine = AudioEngine()
        setupAudioChain()
        configureAudioSession()
        outputMixer.volume = 1.5 // a little gain to make up for quiet sounds
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleAudioSessionInterruption), name: AVAudioSession.interruptionNotification, object: AVAudioSession.sharedInstance())
    }
}

// MARK: Public Methods
public extension MetronomeConductor {
    func start() {
        do {
            // the samplers wipe the audio files when the engine stops, so load them back each time
            try loadAudioSamplesForSoundType(soundType)
            try engine.start()
            engineIsRunning = true
            clock.resume()
            Logger?.log(MetronomeEvent.audioEngineStarted.rawValue,
                        additionalContext: ["object": "Metronome"])
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
            wasRunning = engineIsRunning
            pause()
        } else if type == .ended {
            do {
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                stringKeyedUserInfo.merge(["error": String(describing: error)]) { (current, _) in current }
                Logger?.log(MetronomeEvent.audioSessionSetActiveFailed.rawValue,
                            additionalContext: stringKeyedUserInfo)
            }
            
            if wasRunning {
                pause()
            }
        }
    }
}

// MARK: MetronomeError
enum MetronomeError: Error {
    case primarySoundMissing, secondarySoundMissing
}
