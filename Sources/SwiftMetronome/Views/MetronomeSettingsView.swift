//
//  MetronomeSettingsView.swift
//
//
//  Created by Matt Pfeiffer on 3/21/24.
//

import MediaPlayer
import SwiftUI

public struct MetronomeSettingsView: View {
    @Binding var soundType: MetronomeSound
    @Binding private var boostType: BoostType
    
    public init(soundType: Binding<MetronomeSound>, boostType: Binding<BoostType>) {
        self._soundType = soundType
        self._boostType = boostType
    }
    
    var infoCircle: some View {
        Image(systemName: "info.circle")
            .foregroundStyle(.secondary)
    }
    
    @State private var showingSoundInfo: Bool = false
    @State private var showingBoostInfo: Bool = false
    @State private var showingVolumeInfo: Bool = false

    public var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Metronome Settings")
                .font(.title3)
                .frame(maxWidth: .infinity)
            
            HStack {
                Button {
                    showingSoundInfo = true
                } label: {
                    infoCircle
                }
                .buttonStyle(.plain)
                .buttonBorderShape(.circle)
                .popover(
                    isPresented: $showingSoundInfo, arrowEdge: .bottom
                ) {
                    Text(String.soundInfo)
                        .frame(width: 300)
                        .padding()
                }
                
                Text("Click:")
                Spacer(minLength: 10)
                Picker("Select Sound", selection: $soundType) {
                    ForEach(MetronomeSound.sortedByName, id: \.self) { type in
                        Text(type.name)
                            .tag(type)
                    }                }
                .frame(width: 145)
            }
            
            HStack {
                Button {
                    showingBoostInfo = true
                } label: {
                    infoCircle
                }
                .buttonStyle(.plain)
                .buttonBorderShape(.circle)
                .popover(
                    isPresented: $showingBoostInfo, arrowEdge: .bottom
                ) {
                    Text(String.boostInfo)
                        .frame(width: 300)
                        .padding()
                }
                
                Text("Boost:")
                Spacer(minLength: 10)
                Picker("Select Boost", selection: $boostType) {
                    ForEach(BoostType.allCases, id: \.self) { boost in
                        Text(boost.name)
                            .tag(boost)
                    }
                }
                .frame(width: 145)
            }
            .padding(.bottom, 10)
            
            VStack(spacing: 18) {
                ZStack {
                    HStack {
                        Button {
                            showingVolumeInfo = true
                        } label: {
                            infoCircle
                        }
                        .buttonStyle(.plain)
                        .buttonBorderShape(.circle)
                        .popover(
                            isPresented: $showingVolumeInfo, arrowEdge: .bottom
                        ) {
                            Text(String.systemVolumeInfo)
                                .frame(width: 300)
                                .padding()
                        }
                        Spacer()
                    }
                    Text("System Volume")
                }
                
                VolumeSliderWithPreviewCompatibility()
            }
            
            Spacer(minLength: 0)
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
        StatefulPreviewWrapper(BoostType.normal) { boost in
            MetronomeSettingsView(soundType: value, boostType: boost)
                .frame(width: 300)
        }
    }
}

extension String {
    static var soundInfo: String {
        "The sound that the metronome makes."
    }
    
    static var boostInfo: String {
        "Changes click loudness without affecting the overall system volume."
    }
    
    static var systemVolumeInfo: String {
        "Adjusts Vision Pro system volume."
    }
}
