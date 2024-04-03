//
//  MetronomeView.swift
//  SpatialTuner
//
//  Created by Matt Pfeiffer on 2/29/24.
//

import SwiftUI
import TipKit

public struct MetronomeView: View {
    @State var metronome: MetronomeConductor
    
    public init(metronome: MetronomeConductor) {
        self.metronome = metronome
    }
    
    private var knobTip = KnobTip()
    
    public var body: some View {
        ZStack {
            VStack {
                HStack {
                    TimeSignatureMenu(timeSignature: $metronome.clock.timeSignature)
                        .padding(.leading)
                        .padding(.top, 15)
                    
                    Spacer()
                    
                    SubdivisionMenu(subdivision: $metronome.clock.subdivision, timeSignature: metronome.clock.timeSignature)
                        .padding(.trailing)
                        .padding(.top, 15)
                }
                
                Spacer()
            }
            .foregroundStyle(.secondary)
            
            ArcKnobView(tempo: $metronome.clock.tempoBPM)
                .frame(width: 225, height: 225)
            
            TipView(knobTip, arrowEdge: .bottom)
                .offset(y: -90)
            
            CurrentBeatIndicatorCircleGrid(isRunning: metronome.clock.isRunning,
                                           currentBeat: metronome.clock.currentBeat,
                                           numberOfBeats: metronome.clock.timeSignature.numerator)
        }
        .padding(.vertical)
    }
    
    struct TimeSignatureMenu: View {
        @Binding var timeSignature: TimeSignature

        var body: some View {
            Menu {
                ForEach(TimeSignature.allCases, id: \.self) { timeSignature in
                    Button(action: {
                        self.timeSignature = timeSignature
                    }) {
                        Text(timeSignature.menuTextHacked)
                    }
                }
            } label: {
                Text(timeSignature.fractionText)
                    .frame(width: 45, height: 25)
            }
            .buttonStyle(.plain)
        }
    }
    
    struct SubdivisionMenu: View {
        @Binding var subdivision: Subdivision
        let timeSignature: TimeSignature
        
        var body: some View {
            Menu {
                ForEach(Subdivision.allCases, id: \.self) { subdivision in
                    Button(action: {
                        self.subdivision = subdivision
                    }) {
                        Label {
                            Text(subdivision.getNameForTimeSignature(timeSignature))
                        } icon: {
                            Image(subdivision.getImageForTimeSignature(timeSignature), bundle: .module)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 20)
                        }
                    }
                }
            } label: {
                Image(subdivision.getImageForTimeSignature(timeSignature), bundle: .module)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 38, height: 16)
                    .padding(4)
            }
            .buttonStyle(.plain)
        }
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
                                        .padding(index == 0 ? 1 : 2)
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
                                            .padding(index == 0 ? 1 : 2)
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
    
    struct KnobTip: Tip {
        var title: Text {
            Text("Adjust Tempo")
        }
        
        var message: Text? {
            Text("Pinch and drag the knob to adjust the tempo of the metronome.")
        }
    }
}

#Preview("Metronome", windowStyle: .automatic, traits: .fixedLayout(width: 300, height: 300)) {
    MetronomeView(metronome: MetronomeConductor())
}
