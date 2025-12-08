//
//  AppleMusicTokenResponse.swift
//  listBridge
//
//  Created by Anıl Aygün on 27.11.2025.
//

import Foundation

struct AppleMusicTokenResponse : Codable {
    
    let developerToken: String
    let expiresIn: String
    
    enum CodingKeys: String, CodingKey {
        case developerToken = "token"
        case expiresIn = "expiresAt"
    }
}

