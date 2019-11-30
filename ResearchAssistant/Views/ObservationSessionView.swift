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
            Divider()
            HStack {
                Text("Trial:")
                TextField("e.g. - 1", text: self.$session.trialNumber)
            }
            Divider()
            HStack {
                Text("Day:")
                TextField("e.g. - 2", text: self.$session.trialDayNumber)
            }
            Divider()
            HStack {
                Text("Duration (sec):")
                TextField("e.g. - 300", text: self.$session.duration)
                
            }
            Divider()
        }
        .padding([.bottom], 16)
    }
    
    var itemCards: some View {
        ForEach(Array(stride(from: 0, to: self.session.items.count, by: 2)), id: \.self) { index in
            HStack(alignment: .center) {
                VStack {
                    ObservedItemCard(item: self.session.items[index])
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                
                VStack {
                    if index + 1 < self.session.items.count {
                        ObservedItemCard(item: self.session.items[index+1])
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity)
            }
        }
    }
    
    var notBegunActions: some View {
        VStack {
            Button(action: { self.session.addItem(id: "") }) {
                Spacer()
                Text("Add Item").foregroundColor(.white)
                Spacer()
            }
            .boldRoundedBackground(with: .blue)
            .padding([.top, .bottom], 10)
            
            Button(action: self.session.start) {
                Text("Begin Observation")
            }
            .padding([.top, .bottom], 10)
        }
    }
    
    var runningActions: some View {
        Button(action: { self.session.stop() }) {
            Spacer()
            Text("End Observation").foregroundColor(.white)
            Spacer()
        }
        .boldRoundedBackground(with: .red)
        .padding([.top, .bottom], 10)
    }
    
    var completeActions: some View {
        VStack {
            Button(action: {
                self.activityViewController.shareFiles(fileURLs: self.session.export())
            }) {
                
                ZStack {
                    HStack{
                        Spacer()
                        Image(systemName: "square.and.arrow.up").foregroundColor(.white)
                        Text("Share").foregroundColor(.white)
                        Spacer()
                    }
                    
                    self.activityViewController
                }
            }
            .boldRoundedBackground(with: .blue)
            .padding([.top, .bottom], 10)
            
            Button(action: { self.session.reset() }) { Text("Start Over") }.padding([.top, .bottom], 10)
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
            .padding()
            .frame(width: geometry.size.width)
        }
        .navigationBarTitle("SwitchWatch", displayMode: .inline)
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    
    static var session: ObservationSession {
        let session = ObservationSession(groupName: "Family A")
        session.addItem(id: "1")
        session.addItem(id: "2")
        session.addItem(id: "")
        session.state = .complete
        return session
    }
    
    static var previews: some View {
        Group {
            ObservationSessionView(session: ContentView_Previews.session)
        }
    }
}
#endif
