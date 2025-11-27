//
//  SpotifyTokenManager.swift
//  listBridge
//
//  Created by Anıl Aygün on 27.11.2025.
//

import Foundation

class SpotifyTokenManager {
    
    static let shared = SpotifyTokenManager()
    private init() {}
    
    func saveTokens(accessToken: String, refreshToken: String) async  {
        await KeychainService.shared.saveString(accessToken,
                                    service: SpotifyKeys.service,
                                    account:SpotifyKeys.accessAccount)
        await KeychainService.shared.saveString(refreshToken,
                                                service: SpotifyKeys.service,
                                                account: SpotifyKeys.refreshAccount)
    }
    
    func getAccessToken() async -> String? {
        return await KeychainService.shared.readString(service: SpotifyKeys.service,
                                                       account: SpotifyKeys.accessAccount)
    }
    func getRefreshToken() async -> String? {
        return await KeychainService.shared.readString(service: SpotifyKeys.service,
                                                       account: SpotifyKeys.refreshAccount)
    }
    func deleteTokens() async {
        await KeychainService.shared.delete(service: SpotifyKeys.service,
                                            account: SpotifyKeys.accessAccount)
        await KeychainService.shared.delete(service: SpotifyKeys.service,
                                            account: SpotifyKeys.refreshAccount)
    }
}
