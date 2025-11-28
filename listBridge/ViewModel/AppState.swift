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
    
    init(authController: AuthController = .shared) {
        self.authController = authController
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
        
        if authController.canFullyLogin {
            self.currentScreen = .main
        } else {
            self.currentScreen = .auth
        }
    }
}
