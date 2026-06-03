//
//  FilePreviewCell.swift
//  DropShelf
//
//  Created by Ravinder Singh on 03/06/26.
//

import SwiftUI
import QuickLookThumbnailing

struct FilePreviewCell: View {

    let item: ShelfItem
    @State private var thumbnail: NSImage?

    var body: some View {

        VStack(spacing: 4) {

            Image(nsImage: thumbnail ?? NSWorkspace.shared.icon(forFile: item.url.path))
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .task {
                    await generateThumbnail()
                }

            Text(item.url.lastPathComponent)
                .font(.caption2)
                .lineLimit(1)
        }
        .frame(width: 60)
        .draggable(item.url)
    }
    
    private func generateThumbnail() async {
        let size = CGSize(width: 100, height: 100)
        let request = QLThumbnailGenerator.Request(fileAt: item.url, size: size, scale: NSScreen.main?.backingScaleFactor ?? 2.0, representationTypes: .thumbnail)
        
        do {
            let rep = try await QLThumbnailGenerator.shared.generateBestRepresentation(for: request)
            await MainActor.run {
                self.thumbnail = rep.nsImage
            }
        } catch {
            // Fallback is handled by the nil coalescing
        }
    }
}
