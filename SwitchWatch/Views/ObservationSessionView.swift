//
//  ObservationSessionView.swift
//  SwitchWatch
//
//  Created by Andrew Moore on 8/9/19.
//  Copyright © 2019 Andrew Moore. All rights reserved.
//

import SwiftUI
import Combine

struct ObservationSessionView: View {
    @ObservedObject var session: ObservationSession
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?

    let activityViewController = SwiftUIFileShareActivityViewController()
    
    var headerView: some View {
        VStack {
            HStack {
                Text("Group:")
                TextField("e.g. - Family A", text: self.$session.groupName)
            }
            Divider()
        }
    }
    
    var itemCards: some View {
        ForEach(Array(stride(from: 0, to: self.session.items.count, by: 2)), id: \.self) { index in
            HStack {
                ObservedItemCard(item: self.session.items[index])
                if index + 1 < self.session.items.count {
                    ObservedItemCard(item: self.session.items[index+1])
                } else {
                    Spacer()
                }
            }
        }
    }
    
    var notBegunActions: some View {
        VStack {
            Button(action: { self.session.addItem(name: "") }) { Text("Add Item") }.padding()
            Button(action: self.session.start) { Text("Begin Observation") }.padding()
        }
    }
    
    var runningActions: some View {
        Button(action: { self.session.stop() }) { Text("End Observation") }.padding()
    }
    
    var completeActions: some View {
        VStack {
            Button(action: {
                
                self.activityViewController.shareFiles(fileURLs: self.session.export())
            }) {
                ZStack {
                    Text("Share")
                    self.activityViewController
                }
            }.frame(width: 60, height: 60)
            Button(action: { self.session.reset() }) { Text("Start Over") }.padding()
        }
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView([.vertical], showsIndicators: false) {
                    self.headerView
                    self.itemCards
                    
                    if self.session.state == .notBegun {
                        self.notBegunActions
                    } else if self.session.state == .running {
                        self.runningActions
                    } else {
                        self.completeActions
                    }
                }
                .frame(width: geometry.size.width)
            }
            .padding()
            .navigationBarTitle(Text("SwitchWatch"), displayMode: .inline)
        }
        
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    
    static var session: ObservationSession {
        let session = ObservationSession(groupName: "Family A")
        session.addItem(name: "1")
        session.addItem(name: "2")
        session.addItem(name: "")
        //session.isRunning = true
        return session
    }
    
    static var previews: some View {
        Group {
            ObservationSessionView(session: ContentView_Previews.session)
        }
    }
}
#endif

