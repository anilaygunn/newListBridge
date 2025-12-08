//
//  listBridgeApp.swift
//  listBridge
//
//  Created by Anıl Aygün on 16.11.2025.
//

import SwiftUI
import Observation
import SwiftData

@main

struct ListBridgeApp: App {
    
    @State private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
        }
        .modelContainer(for: [SpotifyPlaylist.self, ApplePlaylist.self])
    }
}
