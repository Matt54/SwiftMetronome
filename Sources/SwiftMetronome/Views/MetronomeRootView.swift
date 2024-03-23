//
//  SwiftUIView.swift
//  
//
//  Created by Matt Pfeiffer on 3/21/24.
//

import SwiftUI

public struct MetronomeRootView: View {
    @State var metronome = MetronomeConductor()
    var openMainMenuAction: (()->Void)? = nil
    
    public init(metronome: MetronomeConductor = MetronomeConductor(),
                openMainMenuAction: (()->Void)? = nil) {
        self.metronome = metronome
        self.openMainMenuAction = openMainMenuAction
    }
    
    @State private var isShowingSettings = false
    
    public var body: some View {
        let showErrorAlert = Binding<Bool>(
            get: { metronome.errorMessage != nil },
            set: { newValue in
                if !newValue {
                    metronome.errorMessage = nil
                }
            }
        )
        
        Group {
            if isShowingSettings {
                MetronomeSettingsView(soundtype: $metronome.soundType,
                                      openMainMenuAction: openMainMenuAction)
            } else {
                MetronomeView()
            }
        }
        .frame(minWidth: 300, maxWidth: 300, minHeight: 300, maxHeight: 300)
        .ornament(attachmentAnchor: .scene(.topLeading), contentAlignment: .topTrailing) {
            Button("Settings", systemImage: isShowingSettings ? "clock" : "gearshape.fill") {
                isShowingSettings.toggle()
            }
            .labelStyle(.iconOnly)
            
            Button("Play and Pause", systemImage: metronome.clock.isRunning ? "pause.fill" : "play.fill") {
                print("isRunning value: \(metronome.clock.isRunning)")
                if !metronome.clock.isRunning {
                    metronome.start()
                } else {
                    metronome.pause()
                }
            }
            .labelStyle(.iconOnly)
            .animation(nil, value: metronome.clock.isRunning) // remove icon animation
        }
        .onDisappear {
            metronome.pause()
        }
        .alert("Error", isPresented: showErrorAlert) {
            Button("OK", action: {})
        } message: {
            Text(metronome.errorMessage ?? "Something went wrong")
        }
    }
}

#Preview("MetronomeRootView", windowStyle: .automatic, traits: .fixedLayout(width: 300, height: 300)) {
    MetronomeRootView()
}
