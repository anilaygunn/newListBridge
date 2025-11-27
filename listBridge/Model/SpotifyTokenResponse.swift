//
//  SpotifyTokenResponse.swift
//  listBridge
//
//  Created by Anıl Aygün on 20.11.2025.
//

import Foundation

struct SpotifyTokenResponse: Codable {
    let accessToken: String?
    let refreshToken: String?
    let expiresIn: Int

}
