//
//  DropShelfApp.swift
//  DropShelf
//
//  Created by Ravinder Singh on 03/06/26.
//

import SwiftUI
import Combine

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        
        ShakeDetector.shared.onShake = {
            WindowManager.shared.showShelf()
        }
        ShakeDetector.shared.start()
    }
}

@main
struct DropShelfApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra("DropShelf", systemImage: "tray.and.arrow.down.fill") {
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
    }
}
