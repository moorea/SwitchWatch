//
//  ObservedItem.swift
//  SwitchWatch
//
//  Created by Andrew Moore on 8/10/19.
//  Copyright © 2019 Andrew Moore. All rights reserved.
//

import Foundation
import Combine

enum CurrentArea: Int {
    case areaOne = 1
    case areaTwo = 2
}

class ObservedItem: ObservableObject, Identifiable {
    let objectWillChange = ObservableObjectPublisher()
    var id = UUID()
    var name: String
    
    private var transitions: [String] = []
    
    private let tickInterval: TimeInterval = 0.5
    private var timer: Timer?
    private var timerStartTime: TimeInterval = 0
    private var timerElapsedTime: TimeInterval = 0
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
    
    var currentArea: CurrentArea = .areaOne {
        didSet {
            if timerElapsedTime > 0 {
                recordTransition()
            }
        }
    }
    
    init(name: String) {
        self.name = name
    }
    
    //MARK: - Timer Control
    
    func start() {
        recordInitialPositions()
        timer = Timer.scheduledTimer(timeInterval: tickInterval, target: self,
                                     selector: #selector(timerHasTicked(timer:)),
                                     userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: RunLoop.Mode.common)
        timerStartTime = Date.timeIntervalSinceReferenceDate
    }
    
    func stop() {
        recordFinalPositions()
        timer?.invalidate()
    }
    
    @objc private func timerHasTicked(timer: Timer) {
        
        let currentTime = Date.timeIntervalSinceReferenceDate
        timerElapsedTime = (currentTime - timerStartTime)
        objectWillChange.send()
        
        switch currentArea {
        case .areaOne:
            areaOneElapsedTime += tickInterval
            break
        case .areaTwo:
            areaTwoElapsedTime += tickInterval
            break
        }
    }
    
    //MARK: - Data Export
    
    func constructAllTransitionsCSV() -> String {
        var csv = ""
        transitions.forEach { transition in
            csv += transition
        }
        return csv
    }
    
    func constructOverallStatsCSV() -> String {
        return "\(name),\(formattedTimeOne),\(formattedTimeTwo),\(transitions.count - 2)\n"
    }
    
    //MARK: - Transition Recording
    
    private func recordTransition() {
        switch currentArea {
        case .areaOne:
            transitions.append("\(name),IntoLight,\(formattedElapsedTime)\n")
            print("Item \(id) switching to light @ \(formattedElapsedTime)")
            break
        case .areaTwo:
            transitions.append("\(name),IntoDark,\(formattedElapsedTime)\n")
            print("Item \(id) switching to dark @ \(formattedElapsedTime)")
            break
        }
    }
    
    private func recordInitialPositions() {
        switch currentArea {
        case .areaOne:
            transitions.append("\(name),BeginLight,\(formattedElapsedTime)\n")
            print("Item \(id) beginning in light @ \(formattedElapsedTime)")
            break
        case .areaTwo:
            transitions.append("\(name),BeginDark,\(formattedElapsedTime)\n")
            print("Item \(id) beginning in dark @ \(formattedElapsedTime)")
            break
        }
    }
    
    private func recordFinalPositions() {
        switch currentArea {
        case .areaOne:
            transitions.append("\(name),EndLight,\(formattedElapsedTime)\n")
            print("Item \(id) ending in light @ \(formattedElapsedTime)")
            break
        case .areaTwo:
            transitions.append("\(name),EndDark,\(formattedElapsedTime)\n")
            print("Item \(id) ending in dark @ \(formattedElapsedTime)")
            break
        }
    }
}
