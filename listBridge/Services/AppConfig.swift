//
//  AppConfig.swift
//  listBridge
//
//  Created by Anıl Aygün on 12.12.2025.
//

import Foundation

struct AppConfig {
    // START: CHANGE THIS IP TO YOUR LOCAL IP
    static let apiBaseURL = "http://localhost:3000/api"
    // END: CHANGE THIS IP TO YOUR LOCAL IP
    
    struct Auth {
        static let spotifyLogin = "\(apiBaseURL)/auth/spotify/login"
        static let spotifyCallback = "\(apiBaseURL)/auth/spotify/callback"
        static let spotifyRefresh = "\(apiBaseURL)/auth/spotify/refresh-token"
        
        static let appleDeveloperToken = "\(apiBaseURL)/auth/apple-music/developer-token"
    }
    
    struct Playlist {
        static let spotify = "\(apiBaseURL)/playlists/spotify/me"
        static let apple = "\(apiBaseURL)/playlists/apple-music/me"
    }
    
    struct Transfer {
        static let spotifyToApple = "\(apiBaseURL)/transfer/spotify-to-apple-music"
        static let appleToSpotify = "\(apiBaseURL)/transfer/apple-music-to-spotify"
    }
}
