//
//  HomeView.swift
//  ResearchAssistant
//
//  Created by Moore, Andrew on 9/13/19.
//  Copyright © 2019 Andrew Moore. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: ObservationSessionView(session: ObservationSession(groupName: ""))) {
                    
                    VStack(alignment: .leading) {
                        Text("SwitchWatch")
                            .font(.headline)
                        Text("Record state transitions over time.")
                            .font(.subheadline)
                    }
                }
            }
            .navigationBarTitle("Home", displayMode: .large)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
