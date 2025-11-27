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
    
    //MARK: -SPOTIFY AUTH
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
    func logInWithSpotify() async{
        Task {
            do {
                
                let authURL = try await self.getSpotifyLoginURL()
                print("Destination URL: \(authURL)")
                
                let callbackScheme = "listBridge"
                
                self.webAuthSession = ASWebAuthenticationSession(
                    url: authURL,
                    callbackURLScheme: callbackScheme
                ) { [weak self] (callbackURL, error) in
                    
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let callbackURL = callbackURL else { return }
                    
                    print("Returned URL: \(callbackURL)")
                    
                    let queryItems = URLComponents(string: callbackURL.absoluteString)?.queryItems
                    
                    let code = queryItems?.filter( { $0.name == "code" } ).first?.value
                    let state = queryItems?.filter( { $0.name == "state" } ).first?.value
                    
                    if let code = code , let state = state {
                        print("Code: \(String(describing: code))")
                        print("State: \(String(describing: state))")
                        
                        Task{
                            try await self?.exchangeCodeForToken(code: code, state: state)
                        }
                    }
                    
                }
                self.webAuthSession?.presentationContextProvider = self
                self.webAuthSession?.prefersEphemeralWebBrowserSession = false
                
                let started = self.webAuthSession?.start()
                print("Is session started: \(String(describing: started))")
                
            } catch {
                print("URL problem: \(error)")
            }
        }
    }
    
    func exchangeCodeForToken(code: String, state: String) async throws{
        
        let spotifyCallbackURL = "\(self.baseURL)/spotify/callback"
        
        var components = URLComponents(string: spotifyCallbackURL)!
        
        components.queryItems = [
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "state", value: state)
        ]
        
        guard let url = components.url else {
            throw AuthError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do{
            
            let(data,response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AuthError.invalidResponseURL
            }
            
            guard (200..<303).contains(httpResponse.statusCode) else {
                throw AuthError.serverError(statusCode: httpResponse.statusCode)
            }
            
            let decoder = JSONDecoder()
            
            let tokenData = try decoder.decode(SpotifyTokenResponse.self, from: data)
            print(tokenData)
            
            
            
        }catch{
            print("Spotify credentials cannot be retrieved.")
        }
    }
    //MARK: -APPLE MUSIC AUTH
    
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
