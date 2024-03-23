//
//  MetronomeSettingsView.swift
//
//
//  Created by Matt Pfeiffer on 3/21/24.
//

import MediaPlayer
import SwiftUI

struct MetronomeSettingsView: View {
    @Binding var soundtype: MetronomeSound
    var openMainMenuAction: (()->Void)? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Settings")
                .font(.title)
                .frame(maxWidth: .infinity)
            
            Spacer()
            
            HStack {
                Text("Sound: ")
                Spacer(minLength: 0)
                Picker("Select Sound", selection: $soundtype) {
                    ForEach(MetronomeSound.sortedByName, id: \.self) { soundType in
                        Text(soundType.name)
                            .tag(soundType)
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(.bottom, 30)
            
            HStack {
                Text("Volume: ")
                VolumeSliderWithPreviewCompatibility()
            }
            
            Spacer()
            
            Spacer()
            
            Button {
                openMainMenuAction?()
            } label: {
                HStack {
                    Image(systemName: "house")
                    Text("Open Main Menu")
                }
            }
            .disabled(openMainMenuAction == nil)
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical)
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
        MetronomeSettingsView(soundtype: value)
    }
}
