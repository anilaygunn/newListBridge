//
//  NetworkManager.swift
//  listBridge
//
//  Created by Anıl Aygün on 16.12.2025.
//

import Foundation

actor NetworkManager {
    static let shared = NetworkManager()
    
    private let authService = AuthService()
    @MainActor
    private let tokenManager = SpotifyTokenManager.shared
    
    private init() {}
    
    func request<T: Decodable>(_ urlRequest: URLRequest) async throws -> T {
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        
        if httpResponse.statusCode == 401 {
           
            return try await handleTokenRefreshAndRetry(originalRequest: urlRequest)
        }
        
        guard httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
    
    private func handleTokenRefreshAndRetry<T: Decodable>(originalRequest: URLRequest) async throws -> T {
        
        guard let refreshToken = await tokenManager.getRefreshToken() else {
             throw URLError(.userAuthenticationRequired)
        }
        
       
        guard let tokenResponse = try await authService.refreshSpotifyToken(refreshToken: refreshToken),
              let newAccessToken = tokenResponse.accessToken else {
             throw URLError(.userAuthenticationRequired)
        }
        
        let newRefreshToken = tokenResponse.refreshToken ?? refreshToken
        await tokenManager.saveTokens(accessToken: newAccessToken, refreshToken: newRefreshToken)
        
        
        var newRequest = originalRequest
        newRequest.setValue("Bearer \(newAccessToken)", forHTTPHeaderField: "Authorization")
        
        let (retryData, retryResponse) = try await URLSession.shared.data(for: newRequest)
        
        guard let retryHttpResponse = retryResponse as? HTTPURLResponse else {
             throw URLError(.badServerResponse)
        }
        
        if retryHttpResponse.statusCode == 401 {
             
             throw URLError(.userAuthenticationRequired)
        }
        
        guard retryHttpResponse.statusCode == 200 else {
             throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: retryData)
    }
    
}
