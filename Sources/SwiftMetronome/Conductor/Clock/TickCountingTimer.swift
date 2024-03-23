//
//  TickCountingTimer.swift
//  SpatialTuner
//
//  Created by Matt Pfeiffer on 3/16/24.
//

import Foundation

/// Book-keeping timer that fires off events based on the tick counting
@Observable
public class TickCountingTimer {
    // MARK: public members
    public var tickEventCallback: ((_ type: TickEventType) -> Void)?
    public var isRunning: Bool = false
    public var timeSignature: TimeSignature = .commonTime
    public var subdivision: Subdivision = .one
    public var tempoBPM: Double = 120 { didSet { throttledUpdater?.update() } }
    public var currentTick: UInt32 = 0
    public var currentBeat: Int = 0
    
    // MARK: private members
    private let ticksPerHit: UInt32 = 24 // sets resolution - more reliable when as as low as possible
    private var throttledUpdater: ThrottledUpdater? // throttles bpm updates
    private var timer: DispatchSourceTimer?
    private let queue = DispatchQueue(label: "com.SpatialTuner.clockTimer", attributes: .concurrent)
    private var ticksPerSubdivision: UInt32 {
        ticksPerHit / subdivision.divisionsPerBeat
    }
    
    public init() {
        createTimer()
        throttledUpdater = ThrottledUpdater(interval: 0.05) {
            let tickInterval = (60.0 / self.tempoBPM) / Double(self.ticksPerHit)
            self.timer?.schedule(deadline: .now(), repeating: tickInterval)
        }
    }
    
    deinit {
        // this seems weird... should it be only cancel if it is running? Why are we resuming to then cancel?
        if !isRunning { timer?.resume() }
        timer?.cancel()
        timer = nil
    }
    
    func pause() {
        if isRunning {
            timer?.suspend()
            isRunning = false
        }
    }
    
    func resume() {
        currentBeat = 0
        currentTick = 0
        tickEventCallback?(.primary)
        if !isRunning {
            timer?.resume()
            isRunning = true
        }
    }
    
    func createTimer() {
        if isRunning {
            timer?.suspend()
        }

        let tickInterval = (60.0 / tempoBPM) / Double(ticksPerHit)
        
        if timer == nil {
            timer = DispatchSource.makeTimerSource(queue: queue)
            timer?.setEventHandler { [weak self] in
                self?.tick()
            }
        }

        timer?.schedule(deadline: .now(), repeating: tickInterval, leeway: .nanoseconds(0))
    }
    
    func tick() {
        currentTick += 1
        
        // check if we've got a subdivision hit
        if currentTick % ticksPerSubdivision == 0 && currentTick % ticksPerHit != 0 {
            tickEventCallback?(.subdivision)
        }

        // check if we've got a beat at this location
        var currentHit = currentBeat
        if currentTick % ticksPerHit == 0 {
            currentHit += 1

            if currentHit % timeSignature.numerator == 0 { // restart at primary
                currentTick = 0
                tickEventCallback?(.primary)
                DispatchQueue.main.async {
                    self.currentBeat = 0
                }
            } else { // secondary beat
                tickEventCallback?(.secondary)
                DispatchQueue.main.async {
                    self.currentBeat = currentHit
                }
            }
        }
    }
}

// MARK: TickEventType
public enum TickEventType {
    case primary, secondary, subdivision
}
