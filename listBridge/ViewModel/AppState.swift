//
//  AppState.swift
//  listBridge
//
//  Created by Anıl Aygün on 16.11.2025.
//

import Foundation
import Observation
import SwiftUI

@Observable
class AppState{
    
    var currentScreen: AppStateType = .splash

    enum AppStateType{
        case splash
        case auth
        case main
    }
    
    init() {
        checkInitalScreen()
    }
    
    func checkInitalScreen(){
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            
            if (self.isUserLoggedIn()){
                
                self.currentScreen = .main
            }
            else{
                self.currentScreen = .auth
            }
            
        }
        
    }
    private func isUserLoggedIn() -> Bool {
        
        return UserDefaults.standard.bool(forKey: "isLoggedIn")
        
    }
    
    
}
