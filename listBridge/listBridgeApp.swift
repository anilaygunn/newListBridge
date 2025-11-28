//
//  listBridgeApp.swift
//  listBridge
//
//  Created by Anıl Aygün on 16.11.2025.
//

import SwiftUI
import Observation

@main
struct YourApp: App {
    
    @State private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            Group {
                switch appState.currentScreen {
                case .splash:
                    SplashView()
                case .auth:
                    AuthView(onLoginSuccess: {
                        appState.currentScreen = .main
                    })
                case .main:
                    ContentView()
                }
            }
            .environment(appState)
            .task{
                await appState.checkInitalScreen()
            }
        }
    }
}
