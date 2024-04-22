//
//  MetronomeSettingsView.swift
//
//
//  Created by Matt Pfeiffer on 3/21/24.
//

import MediaPlayer
import SwiftUI

struct MetronomeSettingsView: View {
    @Binding var soundType: MetronomeSound

    var body: some View {
        VStack(spacing: 0) {
            Text("Metronome Settings")
                .font(.title3)
                .frame(maxWidth: .infinity)
            
            Spacer()
            Spacer()
            
            HStack {
                Text("Sound: ")
                Picker("Select Sound", selection: $soundType) {
                    ForEach(MetronomeSound.sortedByName, id: \.self) { soundType in
                        Text(soundType.name)
                            .tag(soundType)
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(.bottom, 30)
            
            Spacer()
            
            VStack {
                Text("System Volume: ")
                VolumeSliderWithPreviewCompatibility()
            }
            
            Spacer()
        }
        .padding()
        .padding()
    }
    
    // Works on device and in SwiftUI preview, but doesn't display in VisionOS Simulator :(
    struct VolumeSliderWithPreviewCompatibility: View {
        var body: some View {
            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                Slider(value: .constant(0.5), in: 0...1)
                    .frame(height: 20)
            } else {
                VolumeSlider()
                    .frame(height: 20)
            }
        }
        
        struct VolumeSlider: UIViewRepresentable {
            func makeUIView(context: Context) -> MPVolumeView { .init(frame: CGRect.zero) }
            func updateUIView(_ view: MPVolumeView, context: Context) {}
        }
    }
}

#Preview(windowStyle: .automatic, traits: .fixedLayout(width: 300, height: 300)) {
    StatefulPreviewWrapper(MetronomeSound.defaultClick) { value in
        MetronomeSettingsView(soundType: value)
    }
}
