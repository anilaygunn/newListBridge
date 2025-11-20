//
//  SplashView.swift
//  listBridge
//
//  Created by Anıl Aygün on 16.11.2025.
//

import SwiftUI

struct SplashView: View {
    
    var body: some View {
        
        ZStack{
            
            Color.black
                .ignoresSafeArea()

            Image("app_logo")
                .resizable()
                .scaledToFit()
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true),value: 2)
        }
                
    }
}

#Preview {
    SplashView()
}
