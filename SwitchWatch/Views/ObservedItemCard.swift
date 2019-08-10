//
//  ObservedItemCard.swift
//  SwitchWatch
//
//  Created by Andrew Moore on 8/10/19.
//  Copyright © 2019 Andrew Moore. All rights reserved.
//

import Foundation
import SwiftUI

struct ObservedItemCard: View {
    @ObservedObject var item: ObservedItem
    
    var body: some View {
        VStack {
            VStack {
                HStack(alignment: .center, spacing: 4) {
                    Text("ID:")
                        .font(Font.system(size: 13.0))
                        .padding([.leading], 8)
                    TextField("e.g. - 8", text: $item.name)
                        .padding([.leading, .trailing], 8)
                }
                
                Picker(selection: $item.currentArea, label: Text("Picker")) {
                    Text("Light: \(item.formattedTimeOne)").tag(CurrentArea.areaOne)
                    Text("Dark: \(item.formattedTimeTwo)").tag(CurrentArea.areaTwo)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .padding(8)
        }
        .background(Color.tileBackground)
    }
}

#if DEBUG
struct WatchedItemCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ObservedItemCard(item: ObservedItem(name: "Item 1"))
                .previewLayout(PreviewLayout.fixed(width: 200, height: 100))
                .environment(\.colorScheme, .light)
            
            ObservedItemCard(item: ObservedItem(name: "Item 2"))
                .previewLayout(PreviewLayout.fixed(width: 200, height: 100))
                .environment(\.colorScheme, .dark)
        }
    }
}
#endif
