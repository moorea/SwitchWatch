//
//  ObservationSessionView.swift
//  ResearchAssistant
//
//  Created by Andrew Moore on 8/9/19.
//  Copyright © 2019 Andrew Moore. All rights reserved.
//

import SwiftUI
import Combine

struct ObservationSessionView: View {
    @ObservedObject var session: ObservationSession

    let activityViewController = SwiftUIFileShareActivityViewController()
    
    var headerView: some View {
        VStack {
            HStack {
                Text("Group:")
                TextField("e.g. - family_a", text: self.$session.groupName)
            }
            HStack {
                Text("Trial #:")
                TextField("e.g. - 1", text: self.$session.trialNumber)
            }
            HStack {
                Text("Day #:")
                TextField("e.g. - 2", text: self.$session.trialDayNumber)
            }
            HStack {
                Text("Duration (sec):")
                TextField("e.g. - 300", text: self.$session.duration)
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
            Button(action: { self.session.addItem(id: "") }) { Text("Add Item").frame(width: 200) }.padding()
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
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    
    static var session: ObservationSession {
        let session = ObservationSession(groupName: "Family A")
        session.addItem(id: "1")
        session.addItem(id: "2")
        session.addItem(id: "")
        return session
    }
    
    static var previews: some View {
        Group {
            ObservationSessionView(session: ContentView_Previews.session)
        }
    }
}
#endif
