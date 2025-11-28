//
//  AuthController.swift
//  listBridge
//
//  Created by Anıl Aygün on 17.11.2025.
//

import Foundation
import Observation
import AuthenticationServices
import MusicKit
import StoreKit

@Observable
@MainActor
class AuthController: NSObject{
    
    static let shared = AuthController()
    
    private override init(){}
    
    //MARK: -PROPERTIES
    
    let baseURL = "http://localhost:3000/api/auth"
    
    private var webAuthSession: ASWebAuthenticationSession?
    
    var isSpotifyLoggedIn: Bool = false
    var isAppleloggedIn: Bool = false
    
    var canFullyLogin : Bool {
        isAppleloggedIn && isSpotifyLoggedIn
    }
    
    //MARK: -GENERAL AUTH CONTROL
    func checkLoginStatus() async {
        
        guard (await SpotifyTokenManager.shared.getAccessToken()) != nil else {
            
            self.isSpotifyLoggedIn = false
            return
        }
        
        self.isSpotifyLoggedIn = true
        
        let musicStatus = MusicAuthorization.currentStatus
            
        if musicStatus == .authorized {
            
            self.isAppleloggedIn = true
        } else {
            self.isAppleloggedIn = false
        }
    }
    
    
    
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
                        
                        Task{ [weak self] in
                            
                            guard let self else { return }
                            
                            guard let tokenData = try await self.exchangeCodeForToken(code: code, state: state) else {
                                print("HATA: Token verisi boş döndü.")
                                return
                            }

                            await SpotifyTokenManager.shared.saveTokens(
                                accessToken: tokenData.accessToken!,
                                refreshToken: tokenData.refreshToken!
                            )
                            
                            self.isSpotifyLoggedIn = true
                            
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
    
    func exchangeCodeForToken(code: String, state: String) async throws ->SpotifyTokenResponse?{
        
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
            
            return tokenData
            
            
        }catch{
            print("Spotify credentials cannot be retrieved.")
            return nil
        }
    }
    
    func refreshSpotifyToken(refreshToken: String) async throws ->SpotifyTokenResponse?{
        
        let spotifyCallbackURL = "\(self.baseURL)/spotify/refresh-token"
        
        var components = URLComponents(string: spotifyCallbackURL)!
        
        components.queryItems = [
            URLQueryItem(name: "refresh_token", value: refreshToken)
        ]
        guard let url = components.url else {
            throw AuthError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do{
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AuthError.invalidResponseURL
            }
            guard (200..<303).contains(httpResponse.statusCode) else {
                throw AuthError.serverError(statusCode: httpResponse.statusCode)
            }
            let decoder = JSONDecoder()
            
            let spotifyTokenResponse = try decoder.decode(SpotifyTokenResponse.self, from: data)
            
            print(spotifyTokenResponse)
            
            return spotifyTokenResponse
            
        }catch{
            print("Error Refreshing Token")
            return nil
        }

    }
    //MARK: -APPLE MUSIC AUTH
    @MainActor 
    func requestAppleMusicAccess() async{
        let status = await MusicAuthorization.request()
        
        switch status {
        case .authorized:
            print("Access accepted.")
            self.isAppleloggedIn = true
            
        case .denied, .restricted:
            print("Access is denied or limited.")
           
        case .notDetermined:
            print("Acces is not determined.")
        @unknown default:
            print("Unknown situation.")
            
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
    case NoApplePermission
}
