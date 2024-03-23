//
//  MetronomeView.swift
//  SpatialTuner
//
//  Created by Matt Pfeiffer on 2/29/24.
//

import SwiftUI

public struct MetronomeView: View {
    @State var metronome: MetronomeConductor
    
    public init(metronome: MetronomeConductor) {
        self.metronome = metronome
    }
    
    public var body: some View {
        ZStack {
            VStack {
                HStack {
                    Menu {
                        ForEach(TimeSignature.allCases, id: \.self) { timeSignature in
                            Button(action: {
                                metronome.clock.timeSignature = timeSignature
                            }) {
                                Text(timeSignature.menuTextHacked)
                            }
                        }
                    } label: {
                        Text(metronome.clock.timeSignature.fractionText)
                            .frame(width: 45, height: 25)
                    }
                    .buttonStyle(.plain)
                    .padding(.leading)
                    .padding(.top, 15)
                    Spacer()
                    
                    Menu {
                        ForEach(Subdivision.allCases, id: \.self) { subdivision in
                            Button(action: {
                                metronome.clock.subdivision = subdivision
                            }) {
                                Label {
                                    Text(subdivision.getNameForTimeSignature(metronome.clock.timeSignature))
                                } icon: {
                                    Image(subdivision.getImageForTimeSignature(metronome.clock.timeSignature), bundle: .module)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 20)
                                }
                            }
                        }
                    } label: {
                        Image(metronome.clock.subdivision.getImageForTimeSignature(metronome.clock.timeSignature), bundle: .module)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 38, height: 16)
                            .padding(4)
                    }
                    .padding(.trailing)
                    .padding(.top, 15)
                    .buttonStyle(.plain)
                }
                
                Spacer()
            }
            
            .foregroundStyle(.secondary)
            
            ArcKnobView(tempo: $metronome.clock.tempoBPM)
                .frame(width: 225, height: 225)
            
            CurrentBeatIndicatorCircleGrid(isRunning: metronome.clock.isRunning,
                                           currentBeat: metronome.clock.currentBeat,
                                           numberOfBeats: metronome.clock.timeSignature.numerator)
        }
        .padding(.vertical)
    }
    
    struct CurrentBeatIndicatorCircleGrid: View {
        let isRunning: Bool
        let currentBeat: Int
        let numberOfBeats: Int
        
        var body: some View {
            VStack {
                Spacer()
                HStack(spacing: 0) {
                    Spacer(minLength: 0)
                    let firstRowUpperBound = numberOfBeats > 6 ? 6 : numberOfBeats
                    HStack(spacing: 6) {
                        ForEach(0..<firstRowUpperBound, id: \.self) { index in
                            ZStack {
                                Circle()
                                    .stroke()
                                
                                if isRunning && index == currentBeat {
                                    Circle()
                                        .fill(.red)
                                        .padding(index == 0 ? 1 : 4)
                                }
                            }
                            .frame(height: numberOfBeats > 6 ? 12 : 15)
                        }
                    }
                    
                    Spacer(minLength: 0)
                }
                HStack {
                    Spacer()
                    if (numberOfBeats > 6) {
                        HStack(spacing: 6) {
                            ForEach(6..<numberOfBeats, id: \.self) { index in
                                ZStack {
                                    Circle()
                                        .stroke()
                                    
                                    if isRunning && index == currentBeat {
                                        Circle()
                                            .fill(.red)
                                            .padding(index == 0 ? 1 : 4)
                                    }
                                }
                                .frame(height: 12)
                            }
                        }
                    }
                    Spacer()
                }
            }
        }
    }
}

#Preview("Metronome", windowStyle: .automatic, traits: .fixedLayout(width: 300, height: 300)) {
    MetronomeView(metronome: MetronomeConductor())
}
