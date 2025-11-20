//
//  AuthController.swift
//  listBridge
//
//  Created by Anıl Aygün on 17.11.2025.
//

import Foundation
import Observation
import AuthenticationServices

@Observable
class AuthController: NSObject{
    
    let baseURL = "http://localhost:3000/api/auth"
    
    private var webAuthSession: ASWebAuthenticationSession?
    
    func getSpotifyLoginURL() async throws -> URL {
        
        let spotifyLoginURL = "\(self.baseURL)/spotify/login"
        
        guard let url = URL(string: spotifyLoginURL) else {
            throw AuthError.invalidURL
        }
        
        let(data,response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.serverError(statusCode: 0)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw AuthError.serverError(statusCode: httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        
        let result = try decoder.decode(SpotifyLoginResponse.self, from: data)
        
        guard let finalURL = URL(string: result.authURL) else {
            throw AuthError.invalidResponseURL
        }
        
        return finalURL
    }
    
    
    @MainActor
        func logInWithSpotify() {
            Task {
                do {
                    
                    let authURL = try await self.getSpotifyLoginURL()
                    print("Gidilecek URL: \(authURL)")
                    
                    let callbackScheme = "listBridge"
                    
                    self.webAuthSession = ASWebAuthenticationSession(
                        url: authURL,
                        callbackURLScheme: callbackScheme
                    ) { [weak self] (callbackURL, error) in
                        
                        if let error = error {
                            print("Hata oluştu: \(error.localizedDescription)")
                            return
                        }
                        
                        guard let callbackURL = callbackURL else { return }
                        
                        print("Dönen URL: \(callbackURL)")
                        
                    }
                
                    self.webAuthSession?.presentationContextProvider = self
                    self.webAuthSession?.prefersEphemeralWebBrowserSession = false
                    
                    let started = self.webAuthSession?.start()
                    print("Session başlatıldı mı?: \(String(describing: started))")
                    
                } catch {
                    print("URL alınamadı: \(error)")
                }
            }
        }
}

extension AuthController: ASWebAuthenticationPresentationContextProviding {
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow } ?? ASPresentationAnchor()
    }
}

enum AuthError: Error {
    case invalidURL
    case serverError(statusCode: Int)
    case decodingError
    case invalidResponseURL
}
