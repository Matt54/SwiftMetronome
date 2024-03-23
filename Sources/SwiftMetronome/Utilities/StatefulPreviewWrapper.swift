//
//  StatefulPreviewWrapper.swift
//  SpatialTuner
//
//  Created by Matt Pfeiffer on 3/16/24.
//

import SwiftUI

/// Allows for conveniently testing SwiftUI views with bindings for changes
struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State var value: Value
    let content: (Binding<Value>) -> Content

    init(_ value: Value, content: @escaping (Binding<Value>) -> Content) {
        _value = State(initialValue: value)
        self.content = content
    }

    var body: some View {
        content($value)
    }
}
