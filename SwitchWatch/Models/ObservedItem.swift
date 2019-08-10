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
    var id = UUID()
    var name: String
    let objectWillChange = ObservableObjectPublisher()
    
    private(set) var timer: Timer?
    private(set) var timerStartTime: TimeInterval = 0
    private let tick: TimeInterval = 0.5
    
    var timerElapsedTime: TimeInterval = 0
    var areaOneElapsedTime: TimeInterval = 0
    var areaTwoElapsedTime: TimeInterval = 0
    
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
    
    var transitions: [String] = []

    var currentArea: CurrentArea = .areaOne {
        didSet {
            recordTransition()
        }
    }
    
    private func recordTransition() {
        switch currentArea {
        case .areaOne:
            transitions.append("\(name),IntoLight,\(timerElapsedTime)\n")
            print("Item \(id) switching to light @ \(timerElapsedTime)")
            break
        case .areaTwo:
            transitions.append("\(name),IntoDark,\(timerElapsedTime)\n")
            print("Item \(id) switching to dark @ \(timerElapsedTime)")
            break
        }
    }
    
    func start() {
        recordTransition()
        timer = Timer.scheduledTimer(timeInterval: tick, target: self,
                                     selector: #selector(timerHasTicked(timer:)),
                                     userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: RunLoop.Mode.common)
        timerStartTime = Date.timeIntervalSinceReferenceDate
    }
    
    func stop() {
        timer?.invalidate()
    }
    
    @objc private func timerHasTicked(timer: Timer) {
        
        let currentTime = Date.timeIntervalSinceReferenceDate
        timerElapsedTime = (currentTime - timerStartTime)
        objectWillChange.send()
        
        switch currentArea {
        case .areaOne:
            areaOneElapsedTime += tick
            break
        case .areaTwo:
            areaTwoElapsedTime += tick
            break
        }
    }
    
    init(name: String) {
        self.name = name
    }
    
    func constructCSV() -> String {
        var csv = ""
        transitions.forEach { transition in
            csv += transition
        }
        return csv
    }
}
