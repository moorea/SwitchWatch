//
//  ObservationSession.swift
//  SwitchWatch
//
//  Created by Andrew Moore on 8/10/19.
//  Copyright © 2019 Andrew Moore. All rights reserved.
//

import Combine
import Foundation

enum SessionState {
    case notBegun
    case running
    case complete
}

class ObservationSession: ObservableObject {
    let objectWillChange = ObservableObjectPublisher()
    var groupName: String
    var items: [ObservedItem] = []
    var state: SessionState = .notBegun
    
    init(groupName: String) {
        self.groupName = groupName
    }
    
    func addItem(name: String) {
        items.append(ObservedItem(name: name))
        objectWillChange.send()
    }
    
    func start() {
        items.forEach { $0.start() }
        state = .running
        objectWillChange.send()
    }
    
    func stop() {
        items.forEach { $0.stop() }
        state = .complete
        groupName = ""
        objectWillChange.send()
    }
    
    func reset() {
        items = []
        state = .notBegun
        objectWillChange.send()
    }
    
    var exportedRawDataFilePath: URL?
    var exportedStatsFilePath: URL?

    func export() {
        let rawDataFileName = "\(groupName)_raw_transition_times.csv"
        let statsFileName = "\(groupName)_stats.csv"
        
        let rawDataFilePath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(rawDataFileName)
        let statsFilePath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(statsFileName)

        var rawDataCSVText = "id,state,elapsedTime\n"
        items.forEach { item in
            rawDataCSVText += item.constructAllTransitionsCSV()
        }
        
        var statsCSV = "id,elapsedTimeInLight,elapsedTimeInDark,numberOfTransitions\n"
        items.forEach { item in
            statsCSV += item.constructOverallStatsCSV()
        }
        
        do {
            try rawDataCSVText.write(to: rawDataFilePath!, atomically: true, encoding: String.Encoding.utf8)
            try statsCSV.write(to: statsFilePath!, atomically: true, encoding: String.Encoding.utf8)
            exportedRawDataFilePath = rawDataFilePath
            exportedStatsFilePath = statsFilePath
        } catch {
            
            print("Failed to create file")
            print("\(error)")
        }
    }
}
