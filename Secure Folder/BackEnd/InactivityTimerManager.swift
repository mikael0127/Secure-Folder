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
    @Published var remainingTime: TimeInterval = 0
    

    func startTimer(inactivityThreshold: TimeInterval, action: @escaping () async -> Void) {
        isActive = true
        remainingTime = inactivityThreshold // Set remainingTime to inactivityThreshold initially

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            let timeSinceLastInteraction = Date().timeIntervalSince(self.lastInteractionDate)
            let timeLeft = inactivityThreshold - timeSinceLastInteraction // Calculate time left
            self.remainingTime = max(timeLeft, 0) // Update remainingTime, ensure it's not negative
            
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
