//
//  ProgressBar.swift
//  ResearchAssistant
//
//  Created by Andrew Moore on 12/8/19.
//  Copyright © 2019 Andrew Moore. All rights reserved.
//

import SwiftUI
import Combine

struct ProgressBar: View {
    @Binding private(set) var value: Double
    
    private let maxValue: Double
    private let backgroundEnabled: Bool
    private let backgroundColor: Color
    private let foregroundColor: Color
    
    init(value: Binding<Double>,
         maxValue: Double,
         backgroundEnabled: Bool = true,
         backgroundColor: Color = .gray,
         foregroundColor: Color = .blue) {
        
        self._value = value
        self.maxValue = maxValue
        self.backgroundEnabled = backgroundEnabled
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geometryReader in
                if self.backgroundEnabled {
                    Capsule()
                        .foregroundColor(self.backgroundColor)
                }
                
                Capsule()
                    .frame(width:
                        self.progress(value: self.value, maxValue: self.maxValue, width: geometryReader.size.width))
                    .foregroundColor(self.foregroundColor)
                    .animation(.easeIn)
            }
        }
    }
    
    private func progress(value: Double,
                          maxValue: Double,
                          width: CGFloat) -> CGFloat {
        let percentage = value / maxValue
        return width *  CGFloat(percentage)
    }
}


struct ProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        ProgressBar(value: .constant(0.3), maxValue: 1.0)
            .previewLayout(.sizeThatFits)
            .frame(width: 300, height: 20)
    }
}
