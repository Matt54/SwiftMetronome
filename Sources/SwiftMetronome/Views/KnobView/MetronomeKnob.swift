//
//  MetronomeKnob.swift
//  SpatialTuner
//
//  Created by Matt Pfeiffer on 3/16/24.
//

import SwiftUI
import ResizableVector

#Preview("ArcKnobView") {
    StatefulPreviewWrapper(150) { value in
        ArcKnobView(tempo: value)
    }
}

struct ArcKnobView: View {
    @Binding var tempo: Double
    @State var bounds: ClosedRange<CGFloat> = 40...180
    var sensitivity: CGFloat = 0.05
    
    var shapeOnColor: Color = .yellow
    
    var endAngle: Angle {
        Angle(degrees: 265 * tempoBinding.wrappedValue.mapped(from: bounds))
    }
    
    var tempoBinding: Binding<CGFloat> {
        Binding(
            get: { CGFloat(tempo) },
            set: { newValue in
                tempo = newValue
            }
        )
    }

    var body: some View {
        GeometryReader { geo in
            let minorDimension = geo.size.width < geo.size.height ? geo.size.width : geo.size.height
            
            let lineWidth = 25.0 //minorDimension*0.1
            ZStack(alignment: .center) {
                Path { path in
                    path.addArc(center: CGPoint(x: geo.size.width*0.5,
                                                y: geo.size.height*0.5),
                                radius: (minorDimension - minorDimension * 0.05) * 0.5,
                                startAngle: Angle(degrees: 0),
                                endAngle: Angle(degrees: 265),
                                clockwise: false)
                }
                .stroke(.gray, style: .init(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(Angle(degrees: 135))
                .opacity(0.5)
                
                Path { path in
                    path.addArc(center: CGPoint(x: geo.size.width*0.5,
                                                y: geo.size.height*0.5),
                                radius: (minorDimension - minorDimension * 0.05) * 0.5,
                                startAngle: Angle(degrees: 0),
                                endAngle: endAngle,
                                clockwise: false)
                }
                .stroke(shapeOnColor, style: .init(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(Angle(degrees: 135))
                
                // static background layer
                // this went off the rails so don't assume it'll look good generally
                ZStack {
                    Circle()
                        .fill(.black)
                    Circle()
                        .stroke(Color.init(white: 0.0125), lineWidth: lineWidth*0.15)
                        .padding(2)
                }
                .frame(width: minorDimension - lineWidth*1.4)
                .allowsHitTesting(false)

                MetronomeKnob(value: tempoBinding,
                              bounds: bounds,
                              sensitivity: sensitivity)
                    .frame(width: minorDimension - lineWidth*1.4)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

#Preview("DragKnobView") {
    StatefulPreviewWrapper(0.5) { value in
        MetronomeKnob(value: value)
    }
}

struct MetronomeKnob: View {
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
            
            KnobView(percentRotated: turnRatio)
                .gesture(dragGesture)
                .onLongPressGesture(minimumDuration: 0.01,
                                    pressing: { pressing in
                                        isPressed = pressing
                                    }, perform: {})
                // just adds the desired hover effect
                .overlay(
                    ZStack {
                        Text(String(format: "%.0f", value))
                            .font(Font.system(size: 72))
                            .bold()
                            .allowsHitTesting(false)
                        
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
                .scaleEffect(!isPressed ? 1.0 : 0.925)
                .animation(.easeOut, value: isPressed)
                
        }
        .aspectRatio(1.0, contentMode: .fit)
    }
}

#Preview("KnobView") {
    KnobView(percentRotated: .constant(0.5))
}

struct KnobView: View {
    @Binding var percentRotated: CGFloat
    var imageName: String
    var imageBundle: Bundle? = nil
    
    init(percentRotated: Binding<CGFloat>, 
         imageName: String = "Knob16",
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
