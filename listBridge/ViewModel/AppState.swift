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
    private var authController: AuthController
    
    init(authController: AuthController? = nil) {
        self.authController = authController ?? AuthController.shared
    }
    
    func checkInitalScreen() async {
        
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await self.authController.checkLoginStatus()
            }
            
            group.addTask {
                try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
            }
        }
        
        withAnimation {
            if authController.canFullyLogin {
                self.currentScreen = .main
            } else {
                self.currentScreen = .auth
            }
        }
    }
}
