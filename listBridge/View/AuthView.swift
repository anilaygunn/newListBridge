//
//  AuthView.swift
//  listBridge
//
//  Created by Anıl Aygün on 16.11.2025.
//

import SwiftUI

struct AuthView: View {
    
    @Environment(AppState.self) var appState
    
    var onLoginSuccess: () -> Void
    
    var body: some View {
        
        ZStack {
            
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                VStack(spacing: 20){
                    Image("app_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120, alignment: .center)
                        .padding(.top, 60)
                    
                    
                    HStack(spacing: 0) {
                        Text("Sync Your ")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(.white)
                        
                        Text("Vibe")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(
                                
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.4, green: 0.8, blue: 0.5),
                                        Color(red: 0.9, green: 0.4, blue: 0.4)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                    
                    Text("Connect your libraries. Share your world.")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
                
               
                VStack(spacing: 16){
                    
                    Button {
                        Task { @MainActor in
<<<<<<< HEAD
                            await appState.authViewModel.logInWithSpotify()
                            
                            if appState.authViewModel.canFullyLogin{
=======
                            await authController.logInWithSpotify()
                            
                            if authController.canFullyLogin{
>>>>>>> 5898a15 (Auth view updated.)
                                onLoginSuccess()
                            }
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Image("spotify_logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.black)
                            
<<<<<<< HEAD
                            Text(appState.authViewModel.isSpotifyLoggedIn ? "Logged in with Spotify" : "Log in with Spotify")
=======
                            Text(authController.isSpotifyLoggedIn ? "Continue with Spotify" : "Continue with Spotify")
>>>>>>> 5898a15 (Auth view updated.)
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(Color(red: 0.35, green: 0.75, blue: 0.45))
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    Button(action:{
                        Task {
<<<<<<< HEAD
                            await appState.authViewModel.requestAppleMusicAccess()
                            
                            if appState.authViewModel.canFullyLogin {
=======
                            await authController.requestAppleMusicAccess()
                            
                            if authController.canFullyLogin {
>>>>>>> 5898a15 (Auth view updated.)
                                onLoginSuccess()
                            }
                        }
                    }) {
                        HStack(spacing: 12) {
                            
<<<<<<< HEAD
                            Image(systemName: "applelogo") 
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(Color(red: 0.98, green: 0.18, blue: 0.28)) 
                            
                            Text(appState.authViewModel.isAppleloggedIn ? "Logged In with Apple Music" : "Log in with Apple Music")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.black)
=======
                            Image(systemName: "applelogo") // Veya "applelogo"
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(Color(red: 0.98, green: 0.18, blue: 0.28)) // İkon Rengi Kırmızı
                            
                            Text(authController.isAppleloggedIn ? "Continue with Apple Music" : "Continue with Apple Music")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.black) // Yazı Rengi Siyah
>>>>>>> 5898a15 (Auth view updated.)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(Color.white)
                        )
                    }
                    .padding(.horizontal, 24)
                      
                    VStack(spacing: 2) {
                        Text("By continuing, you agree to our Terms and")
                        Text("Privacy Policy.")
                            .underline()
                    }
                    .font(.system(size: 12))
                    .foregroundStyle(.gray.opacity(0.6))
                    .padding(.top, 20)
                    .padding(.bottom, 40)
<<<<<<< HEAD
                }
            }
        }
        .onAppear {
            Task {
                await appState.authViewModel.checkLoginStatus()
                
                if appState.authViewModel.canFullyLogin {
                     onLoginSuccess()
=======
>>>>>>> 5898a15 (Auth view updated.)
                }
            }
        }
    }
}

#Preview {
    AuthView(onLoginSuccess: {})
<<<<<<< HEAD
        .environment(AppState())
=======
>>>>>>> 5898a15 (Auth view updated.)
}
