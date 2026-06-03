//
//  MultiDragView.swift
//  DropShelf
//

import SwiftUI
import AppKit

struct MultiDragOverlay: NSViewRepresentable {
    let urls: [URL]
    let onDragComplete: () -> Void
    
    func makeNSView(context: Context) -> DraggingOverlayView {
        let view = DraggingOverlayView()
        view.urls = urls
        view.onDragComplete = onDragComplete
        return view
    }
    
    func updateNSView(_ nsView: DraggingOverlayView, context: Context) {
        nsView.urls = urls
        nsView.onDragComplete = onDragComplete
    }
}

class DraggingOverlayView: NSView, NSDraggingSource {
    var urls: [URL] = []
    var onDragComplete: (() -> Void)?
    
    override func hitTest(_ point: NSPoint) -> NSView? {
        let view = super.hitTest(point)
        return view == self ? self : view
    }
    
    override var mouseDownCanMoveWindow: Bool {
        return false
    }
    
    override func mouseDown(with event: NSEvent) {
        // Required to receive mouseDragged
    }
    
    override func mouseDragged(with event: NSEvent) {
        guard !urls.isEmpty else { return }
        
        let draggingItems = urls.map { url -> NSDraggingItem in
            let item = NSDraggingItem(pasteboardWriter: url as NSURL)
            let icon = NSWorkspace.shared.icon(forFile: url.path)
            item.setDraggingFrame(NSRect(x: 0, y: 0, width: 32, height: 32), contents: icon)
            return item
        }
        
        beginDraggingSession(with: draggingItems, event: event, source: self)
    }
    
    func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
        return [.copy, .move]
    }
    
    func draggingSession(_ session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
        if operation != [] {
            onDragComplete?()
        }
    }
}
