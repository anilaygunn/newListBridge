//
//  AuthView.swift
//  listBridge
//
//  Created by Anıl Aygün on 16.11.2025.
//

import SwiftUI

struct AuthView: View {
    
    let authController = AuthController.shared
    
    var onLoginSuccess: () -> Void
    
    var body: some View {
        
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Image("app_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200, alignment: .center)
                    .padding(.top, 40)
                
                //Spotify Button
                Button {
                    Task { @MainActor in
                        await authController.logInWithSpotify()
                        
                        if authController.canFullyLogin{
                            onLoginSuccess()
                        }
                    }
                } label: {
                    HStack(spacing: 12) {
                        
                        ZStack {
                            Image("spotify_logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                        }
                        .frame(width: 40, height: 40)
                        
                        Text(authController.isSpotifyLoggedIn ? "Logged In with Spotify" : "Log In with Spotify" )
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: 300)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color(red: 0.11, green: 0.73, blue: 0.33))
                    )
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
                }
                
                
                //Apple Music Button
                Button(action:{
                    Task {
                        await authController.requestAppleMusicAccess()
                        
                        if authController.canFullyLogin {
                            onLoginSuccess()
                        }
                    }
                }) {
                    HStack(spacing: 12) {
                        
                        ZStack {
                            Image(systemName: "applelogo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                        }
                        .frame(width: 40, height: 40)
                        
                        Text(authController.isAppleloggedIn ? "Logged In with Apple Music" : "Log In with Apple Music")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: 300)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color(red: 0.98, green: 0.18, blue: 0.28))
                    )
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
                }
                
                Spacer()
            }
            .padding()
            
        }
    }
}

