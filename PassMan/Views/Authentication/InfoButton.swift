//
//  InfoButton.swift
//  PassMan
//
//  Created by Vladislav Skotarenko on 14.08.2024.
//

import SwiftUI

struct ContentHeightPreference: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

/// A view that provides a button with an 'info.circle' SF symbol label. When tapped, it displays a popover with content that dynamically adjusts its height to fit, even on devices where popovers typically expand to full-screen sheets.
struct InfoButton: View {
    var info: String
    @State private var showPopover: Bool = false
    @State private var textHeight: CGFloat = 0
    
    var body: some View {
        Button(action: {
            showPopover = true
        }, label: {
            Image(systemName: "info.circle")
        })
        .popover(isPresented: $showPopover) {
            Text(info)
                .overlay(
                    GeometryReader { proxy in
                        Color
                            .clear
                            .preference(key: ContentHeightPreference.self,
                                        value: proxy.size.height)
                    }
                )
                .onPreferenceChange(ContentHeightPreference.self) { value in
                    DispatchQueue.main.async {
                        self.textHeight = value
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
                .frame(height: textHeight)
                .padding()
                .presentationCompactAdaptation(.none)
        }
    }
}

#Preview {
    InfoButton(info: "test text")
}
