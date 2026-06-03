//
//  ShakeDetector.swift
//  DropShelf
//

import AppKit
import Foundation

class ShakeDetector {
    static let shared = ShakeDetector()
    
    var onShake: (() -> Void)?
    
    struct PointRecord {
        let point: NSPoint
        let time: Date
    }
    
    private var history: [PointRecord] = []
    private var lastShakeTime: Date = Date.distantPast
    private var timer: Timer?
    
    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] _ in
            self?.checkMouseMovement()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        history.removeAll()
    }
    
    private func checkMouseMovement() {
        // Only track shakes if the user is holding down a mouse button (e.g., during a drag)
        guard NSEvent.pressedMouseButtons != 0 else {
            history.removeAll()
            return
        }
        
        let now = Date()
        let currentLocation = NSEvent.mouseLocation
        
        // Add current location to history
        history.append(PointRecord(point: currentLocation, time: now))
        
        // Remove old points (keep last 0.5 seconds)
        history.removeAll { now.timeIntervalSince($0.time) > 0.5 }
        
        // Don't trigger if we just shook recently
        if now.timeIntervalSince(lastShakeTime) < 1.0 {
            return
        }
        
        // We need at least 10 points to detect a shake
        guard history.count > 10 else { return }
        
        var minX = history[0].point.x
        var maxX = history[0].point.x
        var totalDistance: CGFloat = 0
        var reversals = 0
        
        var currentDirection = 0 // 1 right, -1 left
        
        for i in 1..<history.count {
            let prev = history[i-1].point.x
            let curr = history[i].point.x
            let dx = curr - prev
            
            minX = min(minX, curr)
            maxX = max(maxX, curr)
            totalDistance += abs(dx)
            
            // Only consider significant movement for direction to avoid noise
            if abs(dx) > 2 {
                let dir = dx > 0 ? 1 : -1
                if currentDirection != 0 && dir != currentDirection {
                    reversals += 1
                }
                currentDirection = dir
            }
        }
        
        let width = maxX - minX
        
        // Shake Criteria:
        // 1. Width of movement is at least 40 points
        // 2. Total distance traveled is at least 200 points
        // 3. At least 3 reversals (2-3 shakes)
        if width >= 40 && totalDistance >= 200 && reversals >= 3 {
            lastShakeTime = now
            history.removeAll()
            
            DispatchQueue.main.async {
                self.onShake?()
            }
        }
    }
}
