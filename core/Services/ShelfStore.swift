//
//  ShelfStore.swift
//  DropShelf
//
//  Created by Ravinder Singh on 03/06/26.
//

import SwiftUI
import Combine

final class ShelfStore: ObservableObject {

    @Published var items: [ShelfItem] = []

    func add(urls: [URL]) {
        // By default, just store the references
        items.append(contentsOf: urls.map { ShelfItem(url: $0) })
    }
    
    func addAndMove(urls: [URL]) {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        
        var newURLs: [URL] = []
        for url in urls {
            let destURL = tempDir.appendingPathComponent(url.lastPathComponent)
            do {
                try FileManager.default.moveItem(at: url, to: destURL)
                newURLs.append(destURL)
            } catch {
                print("Failed to move \(url): \(error)")
                newURLs.append(url) // Fallback to original
            }
        }
        
        items.append(contentsOf: newURLs.map { ShelfItem(url: $0) })
    }

    func clear() {
        // Also cleanup temp directories if we moved files
        for item in items {
            if item.url.path.contains(FileManager.default.temporaryDirectory.path) {
                try? FileManager.default.removeItem(at: item.url.deletingLastPathComponent())
            }
        }
        items.removeAll()
    }
}
