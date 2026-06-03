//
//  ShelfView.swift
//  DropShelf
//
//  Created by Ravinder Singh on 03/06/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct ShelfView: View {

    @EnvironmentObject var store: ShelfStore

    var body: some View {

        VStack(spacing: 0) {

            HStack(spacing: 12) {
                Spacer()
                if !store.items.isEmpty {
                    Button {
                        store.clear()
                    } label: {
                        Image(systemName: "trash.circle.fill")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }

                Button {
                    WindowManager.shared.hideShelf()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 10)
            .padding(.trailing, 10)

            VStack(spacing: 12) {

                if store.items.isEmpty {

                    VStack(spacing: 12) {

                        Image(systemName: "tray.and.arrow.down.fill")
                            .font(.system(size: 40))

                        Text("Drop Files Here")
                            .font(.headline)

                        Text("Drag files from Finder")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                } else {

                    ScrollView(.vertical, showsIndicators: true) {
                        LazyVGrid(
                            columns: [
                                GridItem(.adaptive(minimum: 60))
                            ]
                        ) {
                            ForEach(store.items) { item in
                                FilePreviewCell(item: item)
                            }
                        }
                        .padding(.vertical, 4)
                        .overlay(
                            MultiDragOverlay(urls: store.items.map { $0.url }) {
                                store.clear()
                            }
                        )
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 4)

                    Text("\(store.items.count) file(s)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 10)
                }
            }
        }
        .frame(width: 320, height: 180)
        .background(.regularMaterial)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 20
            )
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: 20
            )
            .strokeBorder(
                Color.gray.opacity(0.2),
                lineWidth: 1
            )
        )
        .dropDestination(for: URL.self) { urls, _ in
            let existingURLs = Set(store.items.map { $0.url })
            let newURLs = urls.filter { !existingURLs.contains($0) }
            
            guard !newURLs.isEmpty else { return false }
            
            store.add(urls: newURLs)
            return true
        }
    }
}
