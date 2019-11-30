//
//  BoldRoundedBackgroundModifier.swift
//  ResearchAssistant
//
//  Created by Andrew Moore on 11/30/19.
//  Copyright © 2019 Andrew Moore. All rights reserved.
//

import Foundation
import SwiftUI

extension Button {
    func boldRoundedBackground(with color: Color) -> some View {
        self.modifier(BoldRoundedBackgroundModifier(color: color))
    }
}

struct BoldRoundedBackgroundModifier: ViewModifier {
    var color: Color
    
    func body(content: Content) -> some View {
        return content
            .padding()
            .background(Rectangle().foregroundColor(color))
            .cornerRadius(10.0)
    }
}
