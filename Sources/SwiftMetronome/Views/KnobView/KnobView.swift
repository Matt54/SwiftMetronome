//
//  KnobView.swift
//  SpatialTuner
//
//  Created by Matt Pfeiffer on 3/16/24.
//

import SwiftUI
import ResizableVector

struct KnobView: View {
    @Binding var value: CGFloat
    @State var bounds: ClosedRange<CGFloat> = 0...1
    var sensitivity: CGFloat = 0.25
    
    @State private var isPressed = false
    
    private var turnRatio: Binding<CGFloat> {
        Binding<CGFloat>(get: {
            return $value.wrappedValue.mapped(from: bounds)
        }, set: { newValue in
            value = newValue.mapped(to: bounds)
        })
    }
    
    @State private var location = CGPoint(x: 0, y: 0)
    
    var body: some View {
        GeometryReader { geo in
            let dragGesture = DragGesture(minimumDistance: 0,
                                          coordinateSpace: .local)
                .onChanged { gesture in
                    var delta = CGPoint(x: 0, y: 0)
                                
                    if location.x != 0.0, location.y != 0.0 {
                        delta.x = location.x - gesture.location.x
                        delta.y = location.y - gesture.location.y
                    }
                                
                    location = gesture.location
                                
                    var valueChange = -delta.x/geo.size.width * sensitivity
                    valueChange = valueChange + delta.y/geo.size.width * sensitivity
                                
                    if turnRatio.wrappedValue + valueChange > 1.0 {
                        turnRatio.wrappedValue = 1.0
                    } else if turnRatio.wrappedValue + valueChange < 0.0 {
                        turnRatio.wrappedValue = 0.0
                    } else {
                        turnRatio.wrappedValue = turnRatio.wrappedValue + valueChange
                    }
                }
                .onEnded { _ in
                    location = CGPoint(x: 0, y: 0)
                }
            
            RotatingImageView(percentRotated: turnRatio)
                .gesture(dragGesture)
                .onLongPressGesture(minimumDuration: 0.01,
                                    pressing: { pressing in
                                        isPressed = pressing
                                    }, perform: {})
                .overlay(
                    ZStack {
                        Text(String(format: "%.0f", value))
                            .font(Font.system(size: 68))
                            .bold()
                            .allowsHitTesting(false)
                        
                        Text(TempoMarking.fromTempo(value).rawValue)
                            .offset(y: 48)
                            .foregroundStyle(.secondary)
                            .allowsHitTesting(false)
                        
                        // Hack for adding eye-tracking hover effect
                        Button {
                            print("hello world")
                        } label: {
                            Circle()
                                .fill(.black)
                        }
                        .buttonStyle(.plain)
                        .opacity(0.02)
                        .disabled(true)
                        .buttonBorderShape(.circle)
                        .hoverEffect(.lift)
                    }
                        .padding()
                )
                .scaleEffect(!isPressed ? 1.05 : 0.95)
                .animation(.easeOut, value: isPressed)
                
        }
        .aspectRatio(1.0, contentMode: .fit)
    }
    
    struct RotatingImageView: View {
        @Binding var percentRotated: CGFloat
        var imageName: String
        var imageBundle: Bundle? = nil
        
        init(percentRotated: Binding<CGFloat>,
             imageName: String = "Knob17",
             imageBundle: Bundle? = Bundle.module) {
            self._percentRotated = percentRotated
            
            self.imageName = imageName
            
            if let imageBundle = imageBundle {
                self.imageBundle = imageBundle
            }
        }
        
        var body: some View {
            ResizableVector(imageName, bundle: imageBundle, keepAspectRatio: true)
                .rotationEffect(.degrees(-135 + Double(percentRotated) * 270))
        }
    }
}

#Preview("DragKnobView", windowStyle: .automatic, traits: .fixedLayout(width: 300, height: 300)) {
    StatefulPreviewWrapper(0.5) { value in
        KnobView(value: value)
    }
    .frame(width: 225, height: 225)
}
