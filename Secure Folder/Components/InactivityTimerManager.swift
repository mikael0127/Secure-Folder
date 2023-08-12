//
//  InactivityTimerManager.swift
//  Secure Folder
//
//  Created by Mikael Denys Widjaja on 11/8/23.
//

import Foundation
import Combine

class InactivityTimerManager: ObservableObject {
    private var timer: Timer?
    private var lastInteractionDate: Date = Date()

    @Published var isActive: Bool = false

    func startTimer(inactivityThreshold: TimeInterval, action: @escaping () async -> Void) {
        isActive = true

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            let timeSinceLastInteraction = Date().timeIntervalSince(self.lastInteractionDate)
            if timeSinceLastInteraction > inactivityThreshold {
                Task {
                    await action() // Execute the asynchronous action
                }
                self.invalidateTimer()
            }
        }
    }
    func resetTimer() {
        lastInteractionDate = Date()
    }

    func invalidateTimer() {
        timer?.invalidate()
        isActive = false
    }
}
