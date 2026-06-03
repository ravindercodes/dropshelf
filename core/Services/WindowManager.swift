//
//  WindowManager.swift
//  DropShelf
//

import AppKit
import SwiftUI

class WindowManager {
    static let shared = WindowManager()
    
    private var shelfWindow: NSPanel?
    let store = ShelfStore()
    
    func showShelf() {
        if shelfWindow == nil {
            let panel = NSPanel(
                contentRect: NSRect(x: 0, y: 0, width: 320, height: 180),
                styleMask: [.nonactivatingPanel, .fullSizeContentView, .borderless],
                backing: .buffered,
                defer: false
            )
            
            panel.isFloatingPanel = true
            panel.level = .floating
            panel.backgroundColor = .clear
            panel.hasShadow = true
            panel.isMovableByWindowBackground = true
            
            let shelfView = ShelfView().environmentObject(store)
            let hostingView = NSHostingView(rootView: shelfView)
            
            panel.contentView = hostingView
            shelfWindow = panel
        }
        
        let mouseLocation = NSEvent.mouseLocation
        
        // Position window below the cursor
        let x = mouseLocation.x - 160
        let y = mouseLocation.y - 180 - 10
        
        shelfWindow?.setFrameOrigin(NSPoint(x: x, y: y))
        shelfWindow?.makeKeyAndOrderFront(nil)
    }
    
    func hideShelf() {
        shelfWindow?.orderOut(nil)
    }
}
