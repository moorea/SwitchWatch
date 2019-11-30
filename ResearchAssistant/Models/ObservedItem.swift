//
//  ObservedItem.swift
//  ResearchAssistant
//
//  Created by Andrew Moore on 8/10/19.
//  Copyright © 2019 Andrew Moore. All rights reserved.
//

import Foundation
import Combine

enum CurrentArea: Int {
    case areaA = 1
    case areaB = 2
}

class ObservedItem: ObservableObject, Identifiable {
    var id: String
    
    private var transitions: [String] = []
    
    @Published private var timerElapsedTime: TimeInterval = 0

    private var timerStartTime: TimeInterval = 0
    private var areaOneElapsedTime: TimeInterval = 0
    private var areaTwoElapsedTime: TimeInterval = 0

    private var numberFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 1
        f.minimumFractionDigits = 1
        return f
    }()
    
    var formattedTimeOne: String {
        return numberFormatter.string(from: NSNumber(value: areaOneElapsedTime)) ?? "Error"
    }
    
    var formattedTimeTwo: String {
        return numberFormatter.string(from: NSNumber(value: areaTwoElapsedTime)) ?? "Error"
    }
    
    var formattedElapsedTime: String {
        return numberFormatter.string(from: NSNumber(value: timerElapsedTime)) ?? "Error"
    }
    
    var currentArea: CurrentArea = .areaA {
        didSet {
            if timerElapsedTime > 0 {
                recordTransition()
            }
        }
    }
    
    init(id: String) {
        self.id = id
    }
    
    //MARK: - Timer Control
    
    func start(at initialTime: TimeInterval) {
        timerStartTime = initialTime
        recordInitialPositions()
    }
    
    func update(with elapsedTime: TimeInterval) {
        let tickInterval = elapsedTime - timerElapsedTime

        timerElapsedTime = elapsedTime
        
        switch currentArea {
        case .areaA:
            areaOneElapsedTime += tickInterval
            break
        case .areaB:
            areaTwoElapsedTime += tickInterval
            break
        }
    }
    
    func stop() {
        recordFinalPositions()
    }
    
    //MARK: - Data Export
    
    func constructAllTransitionsCSV(groupName: String, trial: String, day: String) -> String {
        var csv = ""
        transitions.forEach { transition in
            csv += "\(groupName),\(trial),\(day),\(transition)"
        }
        return csv
    }
    
    func constructOverallStatsCSV(groupName: String, trial: String, day: String) -> String {
        return "\(groupName),\(trial),\(day),\(id),\(formattedTimeOne),\(formattedTimeTwo),\(transitions.count - 2)\n"
    }
    
    //MARK: - Transition Recording
    
    private func recordTransition() {
        switch currentArea {
        case .areaA:
            transitions.append("\(id),IntoA,\(formattedElapsedTime)\n")
            break
        case .areaB:
            transitions.append("\(id),IntoB,\(formattedElapsedTime)\n")
            break
        }
    }
    
    private func recordInitialPositions() {
        switch currentArea {
        case .areaA:
            transitions.append("\(id),BeginInA,\(formattedElapsedTime)\n")
            break
        case .areaB:
            transitions.append("\(id),BeginB,\(formattedElapsedTime)\n")
            break
        }
    }
    
    private func recordFinalPositions() {
        switch currentArea {
        case .areaA:
            transitions.append("\(id),EndInA,\(formattedElapsedTime)\n")
            break
        case .areaB:
            transitions.append("\(id),EndB,\(formattedElapsedTime)\n")
            break
        }
    }
}
