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
                            await authController.logInWithSpotify()
                            
                            if authController.canFullyLogin{
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
                            
                            Text(authController.isSpotifyLoggedIn ? "Continue with Spotify" : "Continue with Spotify")
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
                            await authController.requestAppleMusicAccess()
                            
                            if authController.canFullyLogin {
                                onLoginSuccess()
                            }
                        }
                    }) {
                        HStack(spacing: 12) {
                            
                            Image(systemName: "applelogo") // Veya "applelogo"
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(Color(red: 0.98, green: 0.18, blue: 0.28)) // İkon Rengi Kırmızı
                            
                            Text(authController.isAppleloggedIn ? "Continue with Apple Music" : "Continue with Apple Music")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.black) // Yazı Rengi Siyah
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
                }
            }
        }
    }
}

#Preview {
    AuthView(onLoginSuccess: {})
}
