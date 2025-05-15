//
//  ArcKnobView.swift
//  
//
//  Created by Matt Pfeiffer on 3/29/24.
//

import SwiftUI

// Planned on making this generalized, but ended up hardcoding values to move quickly
// Hopefully will come back and refactor into a useful example for the community
struct ArcKnobView: View {
    @Binding var tempo: Double
    @State var bounds: ClosedRange<CGFloat> = 35...250
    var sensitivity: CGFloat = 0.05
    
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
    
    var color: Color {
        return Color.progressGradientColor(from: tempo, in: bounds)
    }

    var body: some View {
        GeometryReader { geo in
            let minorDimension = geo.size.width < geo.size.height ? geo.size.width : geo.size.height
            
            let lineWidth = 25.0
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
                .stroke(color, style: .init(lineWidth: lineWidth, lineCap: .round))
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

                KnobView(value: tempoBinding,
                         bounds: bounds,
                         sensitivity: sensitivity)
                    .frame(width: minorDimension - lineWidth*1.4)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

#Preview("ArcKnobView", windowStyle: .automatic, traits: .fixedLayout(width: 300, height: 300)) {
    StatefulPreviewWrapper(150) { value in
        ArcKnobView(tempo: value)
    }
    .frame(width: 225, height: 225)
}

public extension Color {
    static func progressGradientColor(from value: Double, in range: ClosedRange<CGFloat> = 0...1) -> Color {
        let normalizedValue = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
        let greenComponent: Double
        let redComponent: Double

        if normalizedValue <= 0.5 {
            // From green to yellow
            redComponent = normalizedValue * 2
            greenComponent = 1
        } else {
            // From yellow to red
            redComponent = 1
            greenComponent = 1 - (normalizedValue - 0.5) * 2
        }
        
        return Color(red: redComponent, green: greenComponent, blue: 0)
    }
}
