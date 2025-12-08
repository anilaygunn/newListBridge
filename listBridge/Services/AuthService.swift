import Foundation
import AuthenticationServices
import MusicKit

protocol AuthServiceProtocol {
    func getSpotifyLoginURL() async throws -> URL
    func exchangeCodeForToken(code: String, state: String) async throws -> SpotifyTokenResponse?
    func refreshSpotifyToken(refreshToken: String) async throws -> SpotifyTokenResponse?
    func getAppleDeveloperTokenFromServer() async throws -> String?
    func getAppleMusicUserToken(devToken: String) async throws -> String?
}


class AuthService: AuthServiceProtocol {
    
    private let baseURL = "http://localhost:3000/api/auth"
    
    func getSpotifyLoginURL() async throws -> URL {
        let spotifyLoginURL = "\(self.baseURL)/spotify/login"
        
        guard let url = URL(string: spotifyLoginURL) else {
            throw AuthError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
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
    
    func exchangeCodeForToken(code: String, state: String) async throws -> SpotifyTokenResponse? {
        let spotifyCallbackURL = "\(self.baseURL)/spotify/callback"
        
        var components = URLComponents(string: spotifyCallbackURL)!
        components.queryItems = [
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "state", value: state)
        ]
        
        guard let url = components.url else { throw AuthError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200..<303).contains(httpResponse.statusCode) else {
             if let httpResponse = response as? HTTPURLResponse {
                 throw AuthError.serverError(statusCode: httpResponse.statusCode)
             }
            throw AuthError.invalidResponseURL
        }
        
        let tokenData = try JSONDecoder().decode(SpotifyTokenResponse.self, from: data)
        return tokenData
    }
    
    func refreshSpotifyToken(refreshToken: String) async throws -> SpotifyTokenResponse? {
        let spotifyCallbackURL = "\(self.baseURL)/spotify/refresh-token"
        
        var components = URLComponents(string: spotifyCallbackURL)!
        components.queryItems = [URLQueryItem(name: "refresh_token", value: refreshToken)]
        
        guard let url = components.url else { throw AuthError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200..<303).contains(httpResponse.statusCode) else {
             if let httpResponse = response as? HTTPURLResponse {
                 throw AuthError.serverError(statusCode: httpResponse.statusCode)
             }
             throw AuthError.invalidResponseURL
        }
        
        return try JSONDecoder().decode(SpotifyTokenResponse.self, from: data)
    }
    
    func getAppleDeveloperTokenFromServer() async throws -> String? {
        let appleTokenURL = "\(self.baseURL)/apple-music/developer-token"
        
        guard let url = URL(string: appleTokenURL) else { throw AuthError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let(data,response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200..<303).contains(httpResponse.statusCode) else {
            if let httpResponse = response as? HTTPURLResponse {
                throw AuthError.serverError(statusCode: httpResponse.statusCode)
            } else {
                throw AuthError.invalidResponseURL
            }
        }
        let tokenResponse = try JSONDecoder().decode(AppleMusicTokenResponse.self, from: data)
        
        print("apple token response: \(tokenResponse)")
        return tokenResponse.developerToken
    }
    
    func getAppleMusicUserToken(devToken: String) async throws -> String?{
        
        let status = await MusicAuthorization.request()
            guard status == .authorized else {
            print("Kullanıcı izin vermedi")
            return nil
        }
        
        do{
            
            let provider = MusicUserTokenProvider()
            
            let token = try await provider.userToken(for: devToken,options: [])
    
            print("i get the user token: \(token)")
            return token
            
        }catch {
            print("Apple User Token generation error: \(error)")
            return nil
        }
    }
    
}

enum AuthError: Error {
    case invalidResponseURL
    case serverError(statusCode: Int)
    case invalidURL
    case invalidDevToken
    case decodingError(Error)
}
