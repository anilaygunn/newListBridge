//
//  AppState.swift
//  listBridge
//

import Foundation
import Observation
import SwiftUI

@Observable
@MainActor
class AppState {
    
    enum AppStateType {
        case splash
        case auth
        case main
    }
    
    var currentScreen: AppStateType = .splash
    
    var authViewModel: AuthViewModel
    
    init(authViewModel: AuthViewModel? = nil) {
        self.authViewModel = authViewModel ?? AuthViewModel()
    }
    
    func checkInitalScreen() async {
        
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await self.authViewModel.checkLoginStatus()
            }
            
            group.addTask {
                try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
            }
        }
        
        withAnimation {
            if authViewModel.canFullyLogin {
                self.currentScreen = .main
            } else {
                self.currentScreen = .auth
            }
        }
    }
}
