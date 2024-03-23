//
//  ThrottledUpdater.swift
//  SpatialTuner
//
//  Created by Matt Pfeiffer on 3/16/24.
//

import Foundation

/// Used to prevent continuous value changes to our tempo from causing chaos for our clock timer
class ThrottledUpdater {
    private var timer: DispatchSourceTimer?
    private let queue = DispatchQueue(label: "com.example.throttledUpdater")
    private let interval: TimeInterval
    private let updateAction: () -> Void

    init(interval: TimeInterval, updateAction: @escaping () -> Void) {
        self.interval = interval
        self.updateAction = updateAction
    }

    // I want this to update within value changes, but still wrapping my head around that puzzle..
    func update() {
        timer?.cancel()
        
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer?.schedule(deadline: .now() + interval)

        timer?.setEventHandler { [weak self] in
            self?.updateAction()
        }

        timer?.resume()
    }
}
