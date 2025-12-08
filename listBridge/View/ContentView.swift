//
//  ContentView.swift
//  ContentBridge
//

import SwiftUI

struct ContentView: View {
    
    @Environment(AppState.self) var appState
    
    var body: some View {
        ZStack {
            
            switch appState.currentScreen {
            case .splash:
                SplashView()
                    .transition(.opacity)
            
            case .auth:
                AuthView(onLoginSuccess: {
                    withAnimation {
                        appState.currentScreen = .main
                    }
                })
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                
            case .main:
                MainView()
                    .transition(.opacity)
            }
        }
        
        .animation(.easeInOut(duration: 0.5), value: appState.currentScreen)
        .task {
            
            await appState.checkInitalScreen()
        }
    }
}
