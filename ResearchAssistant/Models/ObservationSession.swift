//
//  ObservationSession.swift
//  ResearchAssistant
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

    var groupName: String
    var trialNumber: String
    var trialDayNumber: String
    var duration: String = "300"
    
    private let tickInterval: TimeInterval = 0.5
    private var timer: Timer?
    private var timerStartTime: TimeInterval = 0
    private var timerElapsedTime: TimeInterval = 0

    @Published private(set) var items: [ObservedItem] = []
    @Published var state: SessionState = .notBegun
    
    init(groupName: String = "", trialNumber: String = "", trialDayNumber: String = "") {
        self.groupName = groupName
        self.trialNumber = trialNumber
        self.trialDayNumber = trialDayNumber
    }
    
    func addItem(id: String) {
        items.append(ObservedItem(id: id))
    }
    
    func start() {
        timer = Timer.scheduledTimer(timeInterval: tickInterval, target: self,
                                     selector: #selector(timerHasTicked(timer:)),
                                     userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: RunLoop.Mode.common)
        
        timerStartTime = Date.timeIntervalSinceReferenceDate
        
        items.forEach { $0.start(at: timerStartTime) }
        
        state = .running
    }
    
    func stop() {
        timer?.invalidate()
        items.forEach { $0.stop() }
        state = .complete
    }
    
    func reset() {
        items = []
        groupName = ""
        state = .notBegun
    }
    
    @objc private func timerHasTicked(timer: Timer) {
        
        let currentTime = Date.timeIntervalSinceReferenceDate
        timerElapsedTime = (currentTime - timerStartTime) * 10 / 10
        let roundedTimerElapsedTime = Double(String(format: "%.1f", timerElapsedTime)) ?? 0
        
        guard roundedTimerElapsedTime <= Double(duration) ?? 0 else {
            stop()
            return
        }
        
        items.forEach { $0.update(with: timerElapsedTime) }
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
            return nil
        }
    }
}
