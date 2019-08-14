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
    var trialNumber: String
    var trialDayNumber: String
    private(set) var items: [ObservedItem] = []
    private(set) var state: SessionState = .notBegun
    
    init(groupName: String = "", trialNumber: String = "", trialDayNumber: String = "") {
        self.groupName = groupName
        self.trialNumber = trialNumber
        self.trialDayNumber = trialDayNumber
    }
    
    func addItem(id: String) {
        items.append(ObservedItem(id: id))
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
        objectWillChange.send()
    }
    
    func reset() {
        items = []
        groupName = ""
        state = .notBegun
        objectWillChange.send()
    }
    
    func export() -> [URL?]? {
        let rawDataFileName = "\(groupName)_raw_transition_times.csv"
        let statsFileName = "\(groupName)_stats.csv"
        
        let rawDataFilePath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(rawDataFileName)
        let statsFilePath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(statsFileName)

        var rawDataCSVText = "group,trial,day,id,event,elapsedTime\n"
        items.forEach { item in
            rawDataCSVText += item.constructAllTransitionsCSV(groupName: groupName, trial: trialNumber, day: trialDayNumber)
        }
        
        var statsCSV = "group,trial,day,id,elapsedTimeInA,elapsedTimeInB,numberOfTransitions\n"
        items.forEach { item in
            statsCSV += item.constructOverallStatsCSV(groupName: groupName, trial: trialNumber, day: trialDayNumber)
        }

        do {
            try rawDataCSVText.write(to: rawDataFilePath!, atomically: true, encoding: String.Encoding.utf8)
            try statsCSV.write(to: statsFilePath!, atomically: true, encoding: String.Encoding.utf8)
            return [rawDataFilePath, statsFilePath]
        } catch {
            print("Failed to create file")
            print("\(error)")
            return nil
        }
    }
}
